/// Structured, **on-device** interview preparation ("Bewerbungstraining").
///
/// Deliberately not an AI mock-interview (that would need the cloud and break
/// the privacy promise): a curated question bank with answer frameworks and
/// tips. General guidance, not individual application coaching.
library;

/// Last editorial review (mirrors the other content review dates).
const String bewerbungReviewedOn = 'Juli 2026';

/// Thematic group of an interview question.
enum InterviewCategory { klassiker, kuendigungErklaeren, gehalt }

extension InterviewCategoryLabel on InterviewCategory {
  String get label => switch (this) {
        InterviewCategory.klassiker => 'Klassische Fragen',
        InterviewCategory.kuendigungErklaeren => 'Kündigung & Lücke erklären',
        InterviewCategory.gehalt => 'Gehaltsverhandlung',
      };
}

/// A single interview question with a way to approach it.
class InterviewQuestion {
  const InterviewQuestion({
    required this.category,
    required this.question,
    required this.approach,
    this.tips = const [],
  });

  final InterviewCategory category;
  final String question;

  /// How to structure a good answer.
  final String approach;

  /// Short, concrete do's.
  final List<String> tips;
}

/// The STAR method, shown as an intro on the training screen.
const String starMethodExplainer =
    'Beantworte Beispiel-Fragen mit der STAR-Methode: '
    'Situation (Ausgangslage) · Task (deine Aufgabe) · Action (was du getan '
    'hast) · Result (das Ergebnis, gern mit Zahl). So werden Stärken konkret '
    'statt behauptet.';

/// Curated question bank.
const List<InterviewQuestion> interviewQuestions = [
  // --- Klassiker ---
  InterviewQuestion(
    category: InterviewCategory.klassiker,
    question: 'Erzählen Sie etwas über sich.',
    approach: 'Ein 2–3-Minuten-Pitch in der Struktur Gegenwart → Vergangenheit '
        '→ Zukunft: Wo stehst du, was hat dich dorthin gebracht, warum diese '
        'Stelle. Nur Berufsrelevantes, kein Lebenslauf zum Vorlesen.',
    tips: [
      'Vorher laut üben und auf die Zeit achten.',
      'Mit einem Satz enden, der zur ausgeschriebenen Stelle überleitet.',
    ],
  ),
  InterviewQuestion(
    category: InterviewCategory.klassiker,
    question: 'Was sind Ihre größten Stärken und Schwächen?',
    approach: 'Stärken mit einem konkreten Beispiel (STAR) belegen, das zur '
        'Stelle passt. Bei der Schwäche eine echte nennen – plus, wie du '
        'aktiv daran arbeitest.',
    tips: [
      'Keine getarnte Stärke („ich bin zu perfektionistisch").',
      'Höchstens zwei Stärken, dafür mit Beleg.',
    ],
  ),
  InterviewQuestion(
    category: InterviewCategory.klassiker,
    question: 'Warum sollten wir gerade Sie einstellen?',
    approach: 'Die zwei, drei wichtigsten Anforderungen der Stelle aufgreifen '
        'und jeweils mit deiner Erfahrung matchen. Nutzen für das Unternehmen '
        'in den Vordergrund stellen, nicht deine Wünsche.',
  ),
  // --- Kündigung & Lücke erklären ---
  InterviewQuestion(
    category: InterviewCategory.kuendigungErklaeren,
    question: 'Warum haben Sie Ihre letzte Stelle verlassen?',
    approach: 'Sachlich und knapp bleiben, nach vorn richten. Betriebsbedingte '
        'Gründe (Umstrukturierung, Stellenabbau) neutral benennen. Nie über '
        'den alten Arbeitgeber schimpfen – das fällt auf dich zurück.',
    tips: [
      'Einen kurzen, ehrlichen Satz vorbereiten und einüben.',
      'Schnell zum Ausblick wechseln: was du jetzt suchst.',
    ],
  ),
  InterviewQuestion(
    category: InterviewCategory.kuendigungErklaeren,
    question: 'Sie haben eine Lücke im Lebenslauf – wie kam es dazu?',
    approach: 'Ehrlich und selbstbewusst: Was hast du in der Zeit getan '
        '(Weiterbildung, Bewerbungsphase, Pflege, Neuorientierung)? Zeig, dass '
        'die Zeit nicht verloren war.',
    tips: ['Kein Rechtfertigen – kurz erklären und weiter.'],
  ),
  InterviewQuestion(
    category: InterviewCategory.kuendigungErklaeren,
    question: 'Dürfen wir Ihren früheren Arbeitgeber kontaktieren?',
    approach: 'Ruhig bleiben. Du kannst auf ein qualifiziertes Zeugnis '
        'verweisen und um Rücksprache bitten, bevor Referenzen kontaktiert '
        'werden – das ist üblich und legitim.',
  ),
  // --- Gehaltsverhandlung ---
  InterviewQuestion(
    category: InterviewCategory.gehalt,
    question: 'Was sind Ihre Gehaltsvorstellungen?',
    approach: 'Vorher den Marktwert recherchieren (Branche, Region, Größe). '
        'Eine Spanne oder einen konkreten Anker nennen, begründet mit deiner '
        'Erfahrung und dem Verantwortungsumfang der Stelle.',
    tips: [
      'Nenne die Zahl selbstbewusst, ohne dich sofort zu rechtfertigen.',
      'Denk an das Gesamtpaket (Urlaub, Homeoffice, Weiterbildung, Bonus).',
    ],
  ),
  InterviewQuestion(
    category: InterviewCategory.gehalt,
    question: 'Ihre Forderung liegt über unserem Rahmen – warum so viel?',
    approach: 'Auf Marktwert und den konkreten Nutzen verweisen, den du '
        'bringst. Gesprächsbereit bleiben, aber nicht sofort einknicken. '
        'Wenn kein Spielraum beim Gehalt ist: über andere Bausteine verhandeln.',
    tips: ['Gehalt verhandelt sich am besten, wenn sie dich schon wollen.'],
  ),
];
