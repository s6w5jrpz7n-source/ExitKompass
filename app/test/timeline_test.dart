import 'package:exitkompass_app/state/wizard.dart';
import 'package:exitkompass_app/timeline/timeline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('timeline', () {
    test('Kündigungsschutzklage-Frist: 3 Wochen ab Zugang, nur bei Kündigung', () {
      final notice = DateTime(2026, 3, 2);
      final data = WizardData(
        situation: Situation.kuendigungErhalten,
        noticeDate: notice,
        exitDate: DateTime(2026, 6, 30),
      );
      final klage = buildTimeline(data).where((i) => i.source == '§ 4 KSchG').toList();
      expect(klage, hasLength(1));
      expect(klage.first.date, DateTime(2026, 3, 23));
      expect(klage.first.urgency, TimelineUrgency.critical);
    });

    test('keine Klagefrist beim reinen Informieren', () {
      final data = WizardData(situation: Situation.nurInfo);
      expect(buildTimeline(data).any((i) => i.source == '§ 4 KSchG'), isFalse);
    });

    test('Arbeitsuchendmeldung: 3 Monate vor Austritt bei langem Vorlauf', () {
      final data = WizardData(
        situation: Situation.kuendigungErhalten,
        noticeDate: DateTime(2026, 1, 1),
        exitDate: DateTime(2026, 9, 1),
      );
      final item = buildTimeline(data).firstWhere((i) => i.source == '§ 38 SGB III');
      expect(item.date, DateTime(2026, 6, 1));
    });

    test('Arbeitsuchendmeldung: 3 Tage nach Kenntnis bei kurzem Vorlauf', () {
      final data = WizardData(
        situation: Situation.kuendigungErhalten,
        noticeDate: DateTime(2026, 5, 10),
        exitDate: DateTime(2026, 6, 1),
      );
      final item = buildTimeline(data).firstWhere((i) => i.source == '§ 38 SGB III');
      expect(item.date, DateTime(2026, 5, 13));
    });

    test('items are sorted by date', () {
      final data = WizardData(situation: Situation.kuendigungErhalten);
      final dates = [
        for (final i in buildTimeline(data))
          if (i.date != null) i.date!,
      ];
      final sorted = [...dates]..sort();
      expect(dates, sorted);
    });
  });
}
