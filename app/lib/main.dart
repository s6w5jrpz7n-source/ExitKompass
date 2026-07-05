import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/app_database.dart';
import 'data/wizard_repository.dart';
import 'screens/onboarding_screen.dart';
import 'state/wizard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local, on-device persistence (no backend/account/cloud, per CLAUDE.md).
  final db = AppDatabase();
  final repository = WizardRepository(db);
  final saved = await repository.load();

  runApp(
    ProviderScope(
      overrides: [
        wizardProvider.overrideWith(
          (ref) => WizardController(repository: repository, initial: saved),
        ),
      ],
      child: const ExitKompassApp(),
    ),
  );
}

class ExitKompassApp extends StatelessWidget {
  const ExitKompassApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF00696E),
      brightness: Brightness.light,
    );
    return MaterialApp(
      title: 'ExitKompass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      home: const OnboardingScreen(),
    );
  }
}
