import 'package:exit_engine/exit_engine.dart';
import 'package:test/test.dart';

void main() {
  group('compareSeveranceTiming', () {
    test('paying in a low-income year keeps more of the severance', () {
      final c = compareSeveranceTiming(
        severanceCents: 5000000, // 50.000 €
        taxableIncomeThisYearCents: 6000000, // 60.000 € salary this year
        taxableIncomeNextYearCents: 0, // unemployed next year
      );
      expect(c.nextYearBetter, isTrue);
      expect(c.gainNextYearCents, greaterThan(0));
      // Next year should keep at least as much net severance.
      expect(c.nextYear.netSeveranceCents,
          greaterThan(c.thisYear.netSeveranceCents));
      // The fifth rule helps most against a low base.
      expect(c.nextYear.fifthRuleUsed, isTrue);
    });

    test('equal income in both years → no timing advantage', () {
      final c = compareSeveranceTiming(
        severanceCents: 4000000,
        taxableIncomeThisYearCents: 4000000,
        taxableIncomeNextYearCents: 4000000,
      );
      expect(c.gainNextYearCents, 0);
      expect(c.nextYearBetter, isFalse);
      expect(c.differenceCents, 0);
    });

    test('net severance is gross minus a non-negative tax', () {
      final c = compareSeveranceTiming(
        severanceCents: 3000000,
        taxableIncomeThisYearCents: 5000000,
        taxableIncomeNextYearCents: 1000000,
      );
      for (final o in [c.thisYear, c.nextYear]) {
        expect(o.taxOnSeveranceCents, greaterThanOrEqualTo(0));
        expect(o.netSeveranceCents, c.severanceCents - o.taxOnSeveranceCents);
        expect(o.netSeveranceCents, lessThanOrEqualTo(c.severanceCents));
      }
    });
  });
}
