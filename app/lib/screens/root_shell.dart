import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/navigation.dart';
import '../widgets/disclaimer_footer.dart';
import 'coach_hub_screen.dart';
import 'finanzen_screen.dart';
import 'ratgeber_screen.dart';
import 'start_hub_screen.dart';

/// The app's home after onboarding: a persistent bottom navigation over the
/// four core areas. The Start hub surfaces every feature; the other tabs are
/// the most-used destinations. The selected tab lives in [rootTabProvider] so
/// other screens can switch areas (e.g. the wizard jumps to Finanzen when
/// done).
class RootShell extends ConsumerWidget {
  const RootShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(rootTabProvider);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: index,
              children: const [
                StartHubScreen(),
                FinanzenScreen(),
                CoachHubScreen(),
                _RatgeberArea(),
              ],
            ),
          ),
          const DisclaimerFooter(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) =>
            ref.read(rootTabProvider.notifier).state = i,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Start'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Finanzen'),
          NavigationDestination(
              icon: Icon(Icons.forum_outlined),
              selectedIcon: Icon(Icons.forum),
              label: 'KI-Coach'),
          NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Ratgeber'),
        ],
      ),
    );
  }
}

/// Wraps the body-only [RatgeberTab] in a Scaffold so it has its own app bar
/// inside the shell.
class _RatgeberArea extends StatelessWidget {
  const _RatgeberArea();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ratgeber')),
      body: const RatgeberTab(),
    );
  }
}
