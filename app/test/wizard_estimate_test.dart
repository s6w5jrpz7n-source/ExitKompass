import 'package:exit_engine/exit_engine.dart';
import 'package:exitkompass_app/state/wizard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WizardData severance-range helper', () {
    test('tenureYears and ageAtExit are derived from the dates', () {
      final data = WizardData(
        birthYear: 1985,
        entryDate: DateTime(2015, 1, 1),
        exitDate: DateTime(2025, 1, 1),
      );
      expect(data.tenureYears, 10);
      expect(data.ageAtExit, 40);
    });

    test('estimateSeveranceRange defaults the strength to the Kündigungsgrund',
        () {
      final data = WizardData(
        kuendigungsArt: KuendigungsArt.verhaltensbedingt, // → schwach
        grossMonthEuro: 5000,
        birthYear: 1985,
        entryDate: DateTime(2015, 1, 1),
        exitDate: DateTime(2025, 1, 1),
      );

      final viaHelper = data.estimateSeveranceRange();
      final direct = estimateSeverance(
        grossMonthCents: data.grossMonthEuro * 100,
        tenureYears: data.tenureYears,
        age: data.ageAtExit,
        strength: KuendigungsArt.verhaltensbedingt.suggestedStrength,
      );

      expect(viaHelper.lowCents, direct.lowCents);
      expect(viaHelper.highCents, direct.highCents);
      expect(viaHelper.pointCents, direct.pointCents);
      // schwach band is 0.25–0.5 of grossMonth × years.
      final base = 5000 * 100 * 10;
      expect(viaHelper.lowCents, (base * 0.25).round());
      expect(viaHelper.highCents, (base * 0.5).round());
    });

    test('an explicit strength overrides the suggested one', () {
      final data = WizardData(
        kuendigungsArt: KuendigungsArt.verhaltensbedingt, // suggests schwach
        grossMonthEuro: 5000,
        entryDate: DateTime(2015, 1, 1),
        exitDate: DateTime(2025, 1, 1),
      );
      final strong = data.estimateSeveranceRange(strength: NegotiationStrength.stark);
      final weak = data.estimateSeveranceRange();
      expect(strong.highCents, greaterThan(weak.highCents));
    });
  });
}
