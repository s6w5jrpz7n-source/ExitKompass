import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One target position: a job ad plus the saved analysis of the CV against it.
/// The CV itself is shared across all profiles (one person, one CV).
class JobProfile {
  const JobProfile({
    required this.id,
    required this.title,
    this.jobAdText = '',
    this.analysis = '',
  });

  final String id;
  final String title;
  final String jobAdText;

  /// The last AI analysis for this position (empty until run).
  final String analysis;

  bool get hasJobAd => jobAdText.trim().isNotEmpty;

  JobProfile copyWith({String? title, String? jobAdText, String? analysis}) =>
      JobProfile(
        id: id,
        title: title ?? this.title,
        jobAdText: jobAdText ?? this.jobAdText,
        analysis: analysis ?? this.analysis,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'title': title, 'jobAd': jobAdText, 'analysis': analysis};

  static JobProfile fromJson(Map<String, dynamic> j) => JobProfile(
        id: j['id'] as String,
        title: j['title'] as String? ?? 'Stelle',
        jobAdText: j['jobAd'] as String? ?? '',
        analysis: j['analysis'] as String? ?? '',
      );
}

/// The user's application documents: one CV (uploaded once, read into plain
/// text) and several job profiles to compare it against. Persisted locally
/// (shared_preferences → IndexedDB on the web); cleared on "Daten löschen".
class ApplicationDocs {
  const ApplicationDocs({
    this.cvText = '',
    this.cvFileName = '',
    this.profiles = const [],
    this.selectedProfileId,
  });

  final String cvText;
  final String cvFileName;
  final List<JobProfile> profiles;
  final String? selectedProfileId;

  bool get hasCv => cvText.trim().isNotEmpty;

  /// The currently active profile (for the analysis screen and the coach).
  JobProfile? get selected {
    for (final p in profiles) {
      if (p.id == selectedProfileId) return p;
    }
    return profiles.isNotEmpty ? profiles.first : null;
  }

  /// Enough material to run a comparison / a role-specific interview.
  bool get isReadyForCoach => hasCv && (selected?.hasJobAd ?? false);

  ApplicationDocs copyWith({
    String? cvText,
    String? cvFileName,
    List<JobProfile>? profiles,
    String? selectedProfileId,
  }) =>
      ApplicationDocs(
        cvText: cvText ?? this.cvText,
        cvFileName: cvFileName ?? this.cvFileName,
        profiles: profiles ?? this.profiles,
        selectedProfileId: selectedProfileId ?? this.selectedProfileId,
      );

  Map<String, dynamic> toJson() => {
        'cv': cvText,
        'cvFile': cvFileName,
        'profiles': [for (final p in profiles) p.toJson()],
        'selected': selectedProfileId,
      };

  static ApplicationDocs fromJson(Map<String, dynamic> j) {
    // Migrate the old single-job-ad format into one profile.
    if (j['profiles'] == null && (j['jobAd'] as String? ?? '').isNotEmpty) {
      final migrated = JobProfile(
        id: 'p_legacy',
        title: 'Stelle 1',
        jobAdText: j['jobAd'] as String,
      );
      return ApplicationDocs(
        cvText: j['cv'] as String? ?? '',
        cvFileName: j['cvFile'] as String? ?? '',
        profiles: [migrated],
        selectedProfileId: migrated.id,
      );
    }
    return ApplicationDocs(
      cvText: j['cv'] as String? ?? '',
      cvFileName: j['cvFile'] as String? ?? '',
      profiles: [
        for (final p in (j['profiles'] as List? ?? const []))
          JobProfile.fromJson(p as Map<String, dynamic>),
      ],
      selectedProfileId: j['selected'] as String?,
    );
  }
}

const _kDocsKey = 'application_docs_v1';

/// Loads the persisted documents. Call once at startup (see main).
Future<ApplicationDocs> loadApplicationDocs() async {
  try {
    final raw = await SharedPreferencesAsync().getString(_kDocsKey);
    if (raw == null) return const ApplicationDocs();
    return ApplicationDocs.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  } catch (_) {
    return const ApplicationDocs();
  }
}

class ApplicationDocsController extends StateNotifier<ApplicationDocs> {
  ApplicationDocsController({ApplicationDocs? initial})
      : super(initial ?? const ApplicationDocs());

  void setCv({required String text, required String fileName}) {
    state = state.copyWith(cvText: text, cvFileName: fileName);
    _persist();
  }

  /// Adds a new empty position and selects it; returns its id.
  String addProfile({String? title}) {
    final id = 'p_${DateTime.now().microsecondsSinceEpoch}';
    final name = title ?? 'Stelle ${state.profiles.length + 1}';
    state = state.copyWith(
      profiles: [...state.profiles, JobProfile(id: id, title: name)],
      selectedProfileId: id,
    );
    _persist();
    return id;
  }

  void updateProfile(String id,
      {String? title, String? jobAdText, String? analysis}) {
    state = state.copyWith(
      profiles: [
        for (final p in state.profiles)
          if (p.id == id)
            p.copyWith(title: title, jobAdText: jobAdText, analysis: analysis)
          else
            p,
      ],
    );
    _persist();
  }

  void deleteProfile(String id) {
    final remaining = [for (final p in state.profiles) if (p.id != id) p];
    state = ApplicationDocs(
      cvText: state.cvText,
      cvFileName: state.cvFileName,
      profiles: remaining,
      selectedProfileId: state.selectedProfileId == id
          ? (remaining.isNotEmpty ? remaining.first.id : null)
          : state.selectedProfileId,
    );
    _persist();
  }

  void selectProfile(String id) {
    state = state.copyWith(selectedProfileId: id);
    _persist();
  }

  void clear() {
    state = const ApplicationDocs();
    _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = SharedPreferencesAsync();
      final snapshot = state;
      if (!snapshot.hasCv && snapshot.profiles.isEmpty) {
        await prefs.remove(_kDocsKey);
        return;
      }
      await prefs.setString(_kDocsKey, jsonEncode(snapshot.toJson()));
    } catch (_) {
      // Best effort – persistence must never break the flow.
    }
  }
}

final applicationDocsProvider =
    StateNotifierProvider<ApplicationDocsController, ApplicationDocs>(
        (ref) => ApplicationDocsController());

/// Builds the context block that carries the CV + a job ad into a coaching
/// session (interview questions tailored to the role, or the document review).
/// Kept text-only so the uploaded file is never re-sent per turn.
String buildDocsContext({required String cvText, required String jobAdText}) {
  final b = StringBuffer();
  if (jobAdText.trim().isNotEmpty) {
    b.writeln('Stellenanzeige:');
    b.writeln(jobAdText.trim());
  }
  if (cvText.trim().isNotEmpty) {
    if (b.isNotEmpty) b.writeln();
    b.writeln('Lebenslauf (aus dem Dokument der Person):');
    b.writeln(cvText.trim());
  }
  return b.toString().trimRight();
}
