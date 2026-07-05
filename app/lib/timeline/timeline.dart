import '../state/wizard.dart';

/// Urgency of a timeline item (drives colour/emphasis).
enum TimelineUrgency { critical, important, info }

/// A single deadline / to-do derived from the user's data.
class TimelineItem {
  const TimelineItem({
    required this.title,
    required this.description,
    required this.source,
    required this.urgency,
    this.date,
  });

  final String title;
  final String description;

  /// Legal source (e.g. `§ 4 KSchG`).
  final String source;
  final TimelineUrgency urgency;

  /// Concrete deadline, if computable; `null` for rule-based items.
  final DateTime? date;
}

DateTime _addDays(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);
DateTime _addMonths(DateTime d, int months) => DateTime(d.year, d.month + months, d.day);
int _monthsBetween(DateTime from, DateTime to) =>
    (to.year - from.year) * 12 + (to.month - from.month);

/// Builds the personalised deadline timeline from the wizard inputs
/// (spec §4 screen 10). Items are general legal information with a source;
/// no individual advice.
List<TimelineItem> buildTimeline(WizardData data) {
  final items = <TimelineItem>[];
  final gotTermination = data.situation == Situation.kuendigungErhalten ||
      data.situation == Situation.aufhebungAngeboten;

  // 1) Kündigungsschutzklage: 3 weeks from receipt (§ 4 KSchG).
  if (gotTermination) {
    items.add(TimelineItem(
      title: 'Frist für die Kündigungsschutzklage',
      description: 'Drei Wochen ab Zugang der schriftlichen Kündigung. Danach gilt die '
          'Kündigung grundsätzlich als wirksam.',
      source: '§ 4 KSchG',
      urgency: TimelineUrgency.critical,
      date: _addDays(data.noticeDate, 21),
    ));
  }

  // 2) Arbeitsuchend melden (§ 38 SGB III).
  final leadMonths = _monthsBetween(data.noticeDate, data.exitDate);
  items.add(TimelineItem(
    title: 'Arbeitsuchend melden',
    description: leadMonths >= 3
        ? 'Spätestens drei Monate vor dem Austritt bei der Agentur für Arbeit melden – '
            'telefonisch, persönlich oder online.'
        : 'Da bis zum Austritt weniger als drei Monate bleiben: innerhalb von drei Tagen '
            'nach Kenntnis der Beendigung melden.',
    source: '§ 38 SGB III',
    urgency: TimelineUrgency.important,
    date: leadMonths >= 3 ? _addMonths(data.exitDate, -3) : _addDays(data.noticeDate, 3),
  ));

  // 3) Arbeitslos melden (first day without employment).
  items.add(TimelineItem(
    title: 'Arbeitslos melden & ALG 1 beantragen',
    description: 'Mit Wirkung ab dem ersten Tag ohne Beschäftigung persönlich oder '
        'online melden und den Antrag stellen.',
    source: '§ 141 SGB III',
    urgency: TimelineUrgency.important,
    date: data.exitDate,
  ));

  // 4) Health insurance in a possible gap.
  items.add(TimelineItem(
    title: 'Krankenversicherung klären',
    description: 'Für die Zeit nach dem Austritt den Krankenversicherungsschutz sichern '
        '(über den ALG-Bezug, freiwillig oder in der Familienversicherung).',
    source: 'SGB V',
    urgency: TimelineUrgency.info,
    date: data.exitDate,
  ));

  // 5) Zeugnis.
  items.add(TimelineItem(
    title: 'Arbeitszeugnis anfordern',
    description: 'Du hast Anspruch auf ein qualifiziertes Arbeitszeugnis – am besten '
        'rechtzeitig vor dem Austritt anfordern.',
    source: '§ 109 GewO',
    urgency: TimelineUrgency.info,
    date: data.exitDate,
  ));

  items.sort((a, b) {
    if (a.date == null && b.date == null) return 0;
    if (a.date == null) return 1;
    if (b.date == null) return -1;
    return a.date!.compareTo(b.date!);
  });
  return items;
}
