import 'package:flutter/material.dart';

import 'non_compete_screen.dart';
import 'vacation_screen.dart';
import 'zeugnis_decoder_screen.dart';

/// A small hub for the additional calculators that don't need a top-level tab.
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void push(Widget screen) => Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => screen));

    return Scaffold(
      appBar: AppBar(title: const Text('Weitere Rechner')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _ToolTile(
            icon: Icons.beach_access_outlined,
            title: 'Resturlaub-Abgeltung',
            subtitle: 'Offene Urlaubstage in Euro (§ 7 IV BUrlG)',
            onTap: () => push(const VacationScreen()),
          ),
          _ToolTile(
            icon: Icons.gavel_outlined,
            title: 'Karenzentschädigung',
            subtitle: 'Wettbewerbsverbot nach dem Job (§§ 74 ff. HGB)',
            onTap: () => push(const NonCompeteScreen()),
          ),
          _ToolTile(
            icon: Icons.translate_outlined,
            title: 'Zeugnis-Decoder',
            subtitle: 'Zeugnissprache in Schulnoten übersetzen',
            onTap: () => push(const ZeugnisDecoderScreen()),
          ),
        ],
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer,
          foregroundColor: cs.onPrimaryContainer,
          child: Icon(icon),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
