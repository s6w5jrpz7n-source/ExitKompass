import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The selected tab of the [RootShell] bottom navigation.
/// 0 = Start, 1 = Abfindung, 2 = Bewerben, 3 = Mehr.
/// Held in a provider so any screen (e.g. the wizard on completion, or a card
/// on the Start hub) can switch the active area without threading callbacks.
final rootTabProvider = StateProvider<int>((ref) => 0);

/// Named indices for the root tabs, to avoid magic numbers at call sites.
/// The app is organised by goal into two pillars — the money/exit side
/// ([abfindung]) and the applying/next-job side ([bewerben]) — plus the
/// [start] dashboard and a [mehr] catch-all.
abstract final class RootTab {
  static const int start = 0;
  static const int abfindung = 1;
  static const int bewerben = 2;
  static const int mehr = 3;
}
