import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../coach/coach_engine.dart';
import '../state/application_docs.dart';
import '../state/coach_session.dart';
import '../state/intake.dart';
import '../state/navigation.dart';
import '../state/wizard.dart';
import '../util/format.dart';
import '../widgets/ui_kit.dart';
import 'coach_screen.dart';
import 'settings_screen.dart';

/// The landing dashboard: the user's situation at a glance, the two goal
/// journeys as big cards, and a "pick up where you left off" for the coach.
/// Cards switch the shell's tab; nothing important is more than a tap away.
class StartHubScreen extends ConsumerWidget {
  const StartHubScreen({super.key});

  void _goTab(WidgetRef ref, int tab) =>
      ref.read(rootTabProvider.notifier).state = tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(wizardProvider);
    final docs = ref.watch(applicationDocsProvider);
    final intake = ref.watch(intakeProvider);
    final sessions = ref.watch(coachSessionProvider);
    final abf = abfindungAccent(context);
    final bew = bewerbenAccent(context);

    void push(Widget screen) => Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => screen));

    // Abfindung status lines. Only show real figures once the user has entered
    // their data (via the wizard / quick-check) – otherwise the defaults would
    // look like example numbers.
    final List<String> abfLines;
    if (intake.done) {
      final r = data.compute();
      final best = r.bestScenario;
      abfLines = [
        'Bestes Szenario '
            '${euroFromCents(r.scenarios[best]!.cumulativeNetCents, withDecimals: false)} netto',
        'Über ${r.horizonMonths} Monate gerechnet',
      ];
    } else {
      abfLines = ['Noch nichts gerechnet', 'Ein paar Angaben genügen'];
    }

    // Bewerben status lines.
    final n = docs.profiles.length;
    final List<String> bewLines;
    if (n == 0 && !docs.hasCv) {
      bewLines = ['Lebenslauf & Stelle hinterlegen', 'Dann Gespräch üben'];
    } else {
      final stellen = n == 1 ? '1 Stelle' : '$n Stellen';
      bewLines = [
        docs.hasCv ? '$stellen · Lebenslauf geprüft' : '$stellen gespeichert',
        'Bewerbungsgespräch üben',
      ];
    }

    // Resume: the first ongoing coach conversation, if any.
    CoachSession? resume;
    for (final m in const [CoachMode.interview, CoachMode.negotiation]) {
      final s = sessions[m];
      if (s != null && s.hasUserTurns) {
        resume = s;
        break;
      }
    }

    return HubScaffold(
      title: 'ExitKompass',
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Einstellungen',
          onPressed: () => push(const SettingsScreen()),
        ),
      ],
      slivers: [
        if (intake.done)
          AppGroup(children: [
            AppRow(
              accent: neutralAccent(context),
              icon: Icons.flag_outlined,
              title: data.situation.label,
              subtitle: data.severanceGrossEuro > 0
                  ? 'Angebot ${euroFromCents(data.severanceGrossEuro * 100, withDecimals: false)}'
                  : 'Deine Angaben',
              onTap: () => _goTab(ref, RootTab.abfindung),
            ),
          ]),
        const SectionLabel('Woran willst du arbeiten?'),
        JourneyCard(
          accent: abf,
          icon: Icons.savings_outlined,
          eyebrow: 'Abfindung & Exit',
          title: 'Was steht dir zu?',
          lines: abfLines,
          cta: 'Zahlen ansehen',
          onTap: () => _goTab(ref, RootTab.abfindung),
        ),
        const SizedBox(height: 13),
        JourneyCard(
          accent: bew,
          icon: Icons.badge_outlined,
          eyebrow: 'Bewerben',
          title: 'Dein nächster Job',
          lines: bewLines,
          cta: 'Weiter üben',
          onTap: () => _goTab(ref, RootTab.bewerben),
        ),
        if (resume != null) ...[
          const SectionLabel('Weiter wo du warst'),
          AppGroup(children: [
            _ResumeRow(session: resume, onTap: () {
              push(CoachScreen(initialMode: resume!.mode));
            }),
          ]),
        ],
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            'Alle Ergebnisse sind Schätzwerte, keine Steuer- oder '
            'Rechtsberatung · 100 % lokal auf deinem Gerät.',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _ResumeRow extends StatelessWidget {
  const _ResumeRow({required this.session, required this.onTap});
  final CoachSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final label = session.mode == CoachMode.negotiation
        ? 'Abfindungsverhandlung'
        : 'Bewerbungsgespräch';
    final last = session.messages.isNotEmpty ? session.messages.last.text : '';
    final snippet =
        last.length > 48 ? '${last.substring(0, 48).trimRight()}…' : last;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 11, 12, 11),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(Icons.play_arrow_rounded, color: accent),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$label · KI',
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 0.4)),
                  Text(
                    snippet.isEmpty ? 'Gespräch fortsetzen' : '„$snippet"',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                size: 20,
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
