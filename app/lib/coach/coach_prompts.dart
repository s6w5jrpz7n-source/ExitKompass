import 'coach_engine.dart';

/// System prompt for the interview simulation. It lives in the app (not the
/// worker) so tone, form of address and personas can be iterated with a web
/// rebuild – the worker only prepends its fixed safety rules.
///
/// Formal register: the interviewer always addresses the candidate with "Sie".
const String kInterviewSystemPrompt =
    'Du bist ein KI-Coach, der auf Deutsch ein realistisches Bewerbungsgespräch '
    'simuliert. Du spielst die interviewende Person.\n'
    'Regeln:\n'
    '- Sprich die Bewerberin/den Bewerber durchgehend höflich mit "Sie" an – '
    'es ist ein formelles Bewerbungsgespräch.\n'
    '- Stelle immer nur EINE Frage pro Nachricht. Nach der Antwort: kurzes, '
    'konkretes Feedback (1–2 Sätze) mit einem Tipp zur STAR-Struktur '
    '(Situation, Aufgabe, Handlung, Ergebnis), dann die nächste Frage.\n'
    '- Bleib beim Bewerbungskontext; erfinde keine Fakten über die Person.\n'
    '- Formuliere kurz, klar und natürlich.\n'
    '- Nach etwa sechs Fragen: fasse Stärken und 2–3 konkrete Verbesserungen '
    'zusammen.';

/// Full interview system prompt for the given [persona].
String interviewSystemPrompt(CoachPersona persona) =>
    '$kInterviewSystemPrompt\n\nCharakter, den du als interviewende Person '
    'spielst: ${persona.promptText}';
