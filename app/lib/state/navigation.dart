import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The selected tab of the [RootShell] bottom navigation.
/// 0 = Start, 1 = Finanzen, 2 = KI-Coach, 3 = Ratgeber.
/// Held in a provider so any screen (e.g. the wizard on completion, or a tile
/// on the Start hub) can switch the active area without threading callbacks.
final rootTabProvider = StateProvider<int>((ref) => 0);

/// Named indices for the root tabs, to avoid magic numbers at call sites.
abstract final class RootTab {
  static const int start = 0;
  static const int finanzen = 1;
  static const int coach = 2;
  static const int ratgeber = 3;
}
