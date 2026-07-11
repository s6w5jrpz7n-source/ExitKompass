import 'package:exitkompass_app/coach/coach_engine.dart';
import 'package:exitkompass_app/state/coach_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a saved conversation is reloaded after a restart', () async {
    CoachSessionController().save(const CoachSession(
      mode: CoachMode.interview,
      persona: CoachPersona.hart,
      messages: [
        CoachMessage(CoachRole.coach, 'Willkommen.'),
        CoachMessage(CoachRole.user, 'Meine Antwort.'),
      ],
    ));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    // Simulate a fresh app start.
    final loaded = await loadCoachSessions();
    final s = loaded[CoachMode.interview]!;
    expect(s.persona, CoachPersona.hart);
    expect(s.messages, hasLength(2));
    expect(s.messages.last.role, CoachRole.user);
    expect(s.messages.last.text, 'Meine Antwort.');
  });

  test('clear() wipes the stored conversations', () async {
    CoachSessionController().save(const CoachSession(
      mode: CoachMode.negotiation,
      persona: CoachPersona.neutral,
      messages: [CoachMessage(CoachRole.user, 'x')],
    ));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    CoachSessionController().clear();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(await loadCoachSessions(), isEmpty);
  });
}
