import 'package:flutter/material.dart';

import '../coach/coach_engine.dart';
import 'coach_screen.dart';
import 'unterlagen_screen.dart';

/// The KI-Coach area (the app's flagship): choose what to practise. Each entry
/// opens the shared chat/analysis screens.
class CoachHubScreen extends StatelessWidget {
  const CoachHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    void push(Widget screen) => Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => screen));

    return Scaffold(
      appBar: AppBar(title: const Text('KI-Coach')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text('Übung, keine Beratung. Wähle, was du trainieren möchtest.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 14),
          _HeroCard(
            title: 'Bewerbungsgespräch',
            body: 'Ein echtes Gespräch – passend zu deinem Lebenslauf und der '
                'Stelle. Die KI stellt die Fragen.',
            cta: 'Gespräch starten',
            onTap: () => push(const CoachScreen()),
          ),
          const SizedBox(height: 10),
          _BigTile(
            icon: Icons.handshake_outlined,
            title: 'Abfindung verhandeln',
            subtitle: 'Die Personalleitung spielt dagegen – mit deinen echten '
                'Zahlen.',
            onTap: () =>
                push(const CoachScreen(initialMode: CoachMode.negotiation)),
          ),
          _BigTile(
            icon: Icons.description_outlined,
            title: 'Unterlagen-Check',
            subtitle: 'Lebenslauf hochladen und mit der Stellenanzeige '
                'abgleichen.',
            badge: 'KI',
            onTap: () => push(const UnterlagenScreen()),
          ),
          const SizedBox(height: 18),
          Card(
            color: cs.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(Icons.tune, size: 20, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Im Gespräch wählst du den Charakter deines Gegenübers: '
                      'freundlich, neutral oder hart.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.body,
    required this.cta,
    required this.onTap,
  });
  final String title;
  final String body;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: cs.primary,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.record_voice_over_outlined,
                      size: 18, color: cs.onPrimary),
                  const SizedBox(width: 8),
                  Text('SIMULATION',
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8)),
                ],
              ),
              const SizedBox(height: 10),
              Text(title,
                  style: theme.textTheme.titleLarge?.copyWith(color: cs.onPrimary)),
              const SizedBox(height: 4),
              Text(body,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: cs.onPrimary.withValues(alpha: 0.9))),
              const SizedBox(height: 14),
              FilledButton.tonalIcon(
                onPressed: onTap,
                icon: const Icon(Icons.play_arrow, size: 18),
                label: Text(cta),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BigTile extends StatelessWidget {
  const _BigTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
        leading: CircleAvatar(
          backgroundColor: cs.secondaryContainer,
          foregroundColor: cs.onSecondaryContainer,
          child: Icon(icon),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        isThreeLine: true,
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.tertiaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(badge!,
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onTertiaryContainer,
                        fontWeight: FontWeight.w800)),
              )
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
