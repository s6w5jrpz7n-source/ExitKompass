/// Golden cases: eight complete profiles through all modules (M1–M4).
///
/// Verified on 2026-07-05 against the official calculators (see
/// `VERIFY.md`): the wage/income tax figures match the BMF calculator
/// **exactly**; the ALG monthly amounts match the Bundesagentur für
/// Arbeit calculator within the spec §5 tolerance of ±2 % (the small
/// deltas stem from the BA's per-step rounding, see ASSUMPTIONS.md
/// A5.2). The `unverified` tag was therefore removed.
library;

import 'package:exit_engine/exit_engine.dart';
import 'package:test/test.dart';

int eur(int euro) => euro * 100;

void main() {
  group('Golden G1 – 60,000 €, class I, childless, 30, no church (NW)', () {
    final net = annualNetIncome(
      grossYearCents: eur(60000),
      taxClass: TaxClass.i,
      age: 30,
    );

    test('taxes and social insurance', () {
      expect(net.taxes.taxableCents, 4664400);
      expect(net.taxes.vorsorgepauschaleCents, 1209000);
      expect(net.taxes.wageTaxCents, 938900, reason: 'BMF: 9.389,00 €');
      expect(net.taxes.soliCents, 0);
      expect(net.taxes.churchTaxCents, 0);
      expect(net.socialInsurance.healthCents, 525000);
      expect(net.socialInsurance.careCents, 144000);
      expect(net.socialInsurance.pensionCents, 558000);
      expect(net.socialInsurance.unempCents, 78000);
    });

    test('net income', () {
      expect(net.netYearCents, 3756100);
      expect(net.netMonthCents, 313008);
    });

    test('ALG 1 (24 insured months); BA: 1.902,60 €/month (Δ 1,20 €, <0,1 %)', () {
      final alg = alg1Benefit(
        grossYearCents: eur(60000),
        taxClass: TaxClass.i,
        age: 30,
      );
      expect(alg.assessedGrossDayCents, 16438);
      expect(alg.benefitBaseDayCents, 10578);
      expect(alg.benefitDayCents, 6346);
      expect(alg.benefitMonthCents, 190380);
      expect(alg1EntitlementDays(insuredMonths: 24, age: 30), 360);
    });
  });

  group('Golden G2 – 90,000 €, class III, 1 child, church 9 % (NW), 40', () {
    final net = annualNetIncome(
      grossYearCents: eur(90000),
      taxClass: TaxClass.iii,
      age: 40,
      childAllowanceFactor: 1,
      totalChildren: 1,
      childrenUnder25: 1,
      churchMember: true,
    );

    test('taxes and social insurance', () {
      expect(net.taxes.taxableCents, 7321400);
      expect(net.taxes.vorsorgepauschaleCents, 1552000);
      expect(net.taxes.wageTaxCents, 1231000, reason: 'BMF: 12.310,00 €');
      expect(net.taxes.soliCents, 0,
          reason: 'assessment basis below the doubled exemption limit');
      expect(net.taxes.churchTaxCents, 84762, reason: 'BMF: 847,62 €');
      expect(net.socialInsurance.healthCents, 610313, reason: 'health capped at ceiling');
      expect(net.socialInsurance.careCents, 125550, reason: 'care 1.8 %, 1 child');
      expect(net.socialInsurance.pensionCents, 837000);
      expect(net.socialInsurance.unempCents, 117000);
    });

    test('net income', () {
      expect(net.netYearCents, 5994375);
      expect(net.netMonthCents, 499531);
    });

    test('ALG 1 with the increased 67 % rate; BA: 3.296,70 €/month (Δ 16,20 €, <0,5 %)',
        () {
      final alg = alg1Benefit(
        grossYearCents: eur(90000),
        taxClass: TaxClass.iii,
        age: 40,
        hasChild: true,
        childAllowanceFactor: 1,
        totalChildren: 1,
        childrenUnder25: 1,
      );
      expect(alg.benefitBaseDayCents, 16353);
      expect(alg.benefitDayCents, 10956);
      expect(alg.benefitMonthCents, 328680);
    });
  });

  group('Golden G3 – 130,000 €, class I, childless, 45 (above both ceilings)', () {
    final net = annualNetIncome(
      grossYearCents: eur(130000),
      taxClass: TaxClass.i,
      age: 45,
    );

    test('taxes and social insurance', () {
      expect(net.taxes.taxableCents, 11173500);
      expect(net.taxes.vorsorgepauschaleCents, 1699900);
      expect(net.taxes.wageTaxCents, 3579300);
      expect(net.taxes.soliCents, 183771, reason: 'taper zone still applies');
      expect(net.socialInsurance.healthCents, 610313);
      expect(net.socialInsurance.careCents, 167400);
      expect(net.socialInsurance.pensionCents, 943020, reason: 'pension capped at ceiling');
      expect(net.socialInsurance.unempCents, 131820);
    });

    test('net income', () {
      expect(net.netYearCents, 7384376);
      expect(net.netMonthCents, 615365);
    });

    test('ALG 1: assessment wage capped at the ceiling → maximum benefit; '
        'BA: 2.810,10 €/month (Δ 2,70 €, <0,1 %)', () {
      final alg = alg1Benefit(
        grossYearCents: eur(130000),
        taxClass: TaxClass.i,
        age: 45,
      );
      expect(alg.assessedGrossYearCents, eur(101400));
      expect(alg.wageTaxYearCents, 2378100);
      expect(alg.soliYearCents, 40828);
      expect(alg.benefitBaseDayCents, 15597);
      expect(alg.benefitDayCents, 9358);
      expect(alg.benefitMonthCents, 280740);
    });
  });

  group('Golden G4 – 75,000 €, class IV, 2 children, no church, 38', () {
    final net = annualNetIncome(
      grossYearCents: eur(75000),
      taxClass: TaxClass.iv,
      age: 38,
      childAllowanceFactor: 2,
      totalChildren: 2,
      childrenUnder25: 2,
    );

    test('taxes and social insurance', () {
      expect(net.taxes.taxableCents, 5978400);
      expect(net.taxes.vorsorgepauschaleCents, 1395000);
      expect(net.taxes.wageTaxCents, 1414900);
      expect(net.taxes.soliCents, 0,
          reason: 'below the exemption limit with 2 child allowances');
      expect(net.socialInsurance.careCents, 108113,
          reason: 'care 1.55 % (discount for the 2nd child), capped at ceiling');
      expect(net.socialInsurance.totalCents, 1513426);
    });

    test('net income', () {
      expect(net.netYearCents, 4571674);
      expect(net.netMonthCents, 380973);
    });
  });

  group('Golden G5 – 45,000 €, class V, 2 children, church 8 % (BY), 35', () {
    final net = annualNetIncome(
      grossYearCents: eur(45000),
      taxClass: TaxClass.v,
      age: 35,
      childAllowanceFactor: 2,
      totalChildren: 2,
      childrenUnder25: 2,
      churchMember: true,
      state: Bundesland.bayern,
    );

    test('taxes and social insurance', () {
      expect(net.taxes.taxableCents, 3504900);
      expect(net.taxes.vorsorgepauschaleCents, 868500);
      expect(net.taxes.wageTaxCents, 1049400,
          reason: '§ 39b Abs. 2 S. 7 (class V); BMF: 10.494,00 €');
      expect(net.taxes.soliCents, 0);
      expect(net.taxes.churchTaxCents, 83952,
          reason: 'class V: 8 % on the full wage tax (no child allowances); BMF: 839,52 €');
      expect(net.socialInsurance.totalCents, 940500);
    });

    test('net income', () {
      expect(net.netYearCents, 2426148);
      expect(net.netMonthCents, 202179);
    });
  });

  group('Golden G6 – severance: 55,000 € rest income + 60,000 € severance, single',
      () {
    final r = severanceComparison(
      taxableIncomeWithoutSeveranceCents: eur(55000),
      severanceCents: eur(60000),
    );

    test('both tax variants and savings', () {
      expect(r.taxWithoutSeveranceCents, 1234700);
      expect(r.taxRegularCents, 3716400);
      expect(r.taxFifthRuleCents, 3570200);
      expect(r.savingsCents, 146200);
      expect(r.refundOnlyViaTaxReturn, isTrue,
          reason: 'refund only via the tax assessment (since 2025)');
    });
  });

  group('Golden G7 – ALG: 95,000 €, class III, 1 child (25 years old), 58, 48 months',
      () {
    final alg = alg1Benefit(
      grossYearCents: eur(95000),
      taxClass: TaxClass.iii,
      age: 58,
      hasChild: true,
      childAllowanceFactor: 1,
      totalChildren: 1,
      childrenUnder25: 0,
    );

    test('assessment and maximum duration', () {
      expect(alg.assessedGrossDayCents, 26027);
      expect(alg.wageTaxYearCents, 1371000);
      expect(alg.benefitBaseDayCents, 17065);
      expect(alg.benefitDayCents, 11433);
      expect(alg.benefitMonthCents, 342990);
      expect(alg1EntitlementDays(insuredMonths: 48, age: 58), 720);
    });

    test('blocking period after a termination agreement: half a year of ALG lost', () {
      final s = blockingPeriodSimulation(
          entitlementDays: 720, benefitDayCents: alg.benefitDayCents);
      expect(s.blockingDays, 84);
      expect(s.reductionDays, 180, reason: 'one quarter of 720 days');
      expect(s.remainingEntitlementDays, 540);
      expect(s.lostBenefitCents, 180 * 11433, reason: '180 × 114.33 € = 20,579.40 €');
    });
  });

  group('Golden G8 – ALG + § 158: 80,000 €, class I, 50, severance 60,000 €', () {
    final alg = alg1Benefit(
      grossYearCents: eur(80000),
      taxClass: TaxClass.i,
      age: 50,
    );

    test('assessment and entitlement duration (30 months, age 50 → 450 days)', () {
      expect(alg.benefitBaseDayCents, 13234);
      expect(alg.benefitDayCents, 7940);
      expect(alg.benefitMonthCents, 238200);
      expect(alg1EntitlementDays(insuredMonths: 30, age: 50), 450);
    });

    test('suspension per § 158: 25 % floor, consumed before the notice period ends',
        () {
      final r = suspension158(
        severanceCents: eur(60000),
        age: 50,
        tenureYears: 25,
        dailyWageCents: eur(80000) ~/ 365,
        missedNoticeDays: 120,
      );
      // 60 % − 5×5 % (25 years tenure) − 3×5 % (age 50) = 20 % → floor 25 %
      expect(r.applicableShare, 0.25);
      expect(r.severanceShareCents, eur(15000));
      expect(r.suspensionDaysUncapped, 68);
      expect(r.suspensionDays, 68,
          reason: 'severance share consumed before the 120 days elapse');
    });
  });
}
