// Preview entrypoint that runs the full app UI without the Drift database
// (in-memory state via the default providers), so it builds and runs on the
// web for screenshots. Build:
//   flutter build web -t tool/preview_app.dart --no-web-resources-cdn
import 'package:exitkompass_app/main.dart';
import 'package:exitkompass_app/state/coach_session.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The coach conversations persist (localStorage on the web) so they survive
  // a page reload even in the preview build.
  final coachSessions = await loadCoachSessions();
  runApp(
    ProviderScope(
      overrides: [
        coachSessionProvider.overrideWith(
          (ref) => CoachSessionController(initial: coachSessions),
        ),
      ],
      child: const ExitKompassApp(),
    ),
  );
}
