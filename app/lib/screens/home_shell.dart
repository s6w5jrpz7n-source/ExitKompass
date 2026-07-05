import 'package:flutter/material.dart';

import '../widgets/disclaimer_footer.dart';
import 'comparison_tab.dart';
import 'ratgeber_screen.dart';
import 'timeline_screen.dart';

/// Post-wizard hub with three tabs: scenario comparison, personalised
/// deadlines and the Ratgeber knowledge base.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _titles = ['Szenario-Vergleich', 'Fristen', 'Ratgeber'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const [ComparisonTab(), TimelineTab(), RatgeberTab()],
            ),
          ),
          const DisclaimerFooter(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Vergleich'),
          NavigationDestination(icon: Icon(Icons.event), label: 'Fristen'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Ratgeber'),
        ],
      ),
    );
  }
}
