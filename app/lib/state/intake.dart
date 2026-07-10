import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the user wants to get out of the app. Captured at the start to frame
/// the hub; not persisted (in-memory, like the rest of the web preview).
enum StartGoal { finanzen, verhandeln, bewerbung, informieren }

extension StartGoalX on StartGoal {
  String get label => switch (this) {
        StartGoal.finanzen => 'Herausfinden, was finanziell rausspringt',
        StartGoal.verhandeln => 'Eine faire Abfindung verhandeln',
        StartGoal.bewerbung => 'Mich auf Bewerbungen vorbereiten',
        StartGoal.informieren => 'Mich erst einmal informieren',
      };

  String get short => switch (this) {
        StartGoal.finanzen => 'Finanzen klären',
        StartGoal.verhandeln => 'Abfindung verhandeln',
        StartGoal.bewerbung => 'Bewerbung vorbereiten',
        StartGoal.informieren => 'Informieren',
      };

  IconData get icon => switch (this) {
        StartGoal.finanzen => Icons.insights_outlined,
        StartGoal.verhandeln => Icons.handshake_outlined,
        StartGoal.bewerbung => Icons.record_voice_over_outlined,
        StartGoal.informieren => Icons.menu_book_outlined,
      };
}

/// The user's chosen goal (null until the intake sets it).
final startGoalProvider = StateProvider<StartGoal?>((ref) => null);

/// Whether the user has been through the short intake. Until then the hub
/// shows a "tell us about your situation" call to action instead of numbers
/// the user never entered.
final intakeDoneProvider = StateProvider<bool>((ref) => false);
