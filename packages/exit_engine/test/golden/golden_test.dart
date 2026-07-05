/// Golden cases: eight complete profiles through all modules (M1–M4).
///
/// The expected values come from the engine's own calculation
/// (regression pins) and are NOT yet externally verified – hence the
/// `unverified` tag. The manual comparison against the BMF wage/income
/// tax calculator and the ALG calculator of the Bundesagentur für
/// Arbeit is described in `VERIFY.md`; the tag is removed once the
/// comparison is confirmed.
@Tags(['unverified'])
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
      expect(net.taxes.taxableCents, 4646400);
      expect(net.taxes.vorsorgepauschaleCents, 1227000);
      expect(net.taxes.wageTaxCents, 932800);
      expect(net.taxes.soliCents, 0);
      expect(net.taxes.churchTaxCents, 0);
      expect(net.socialInsurance.healthCents, 525000);
      expect(net.socialInsurance.careCents, 144000);
      expect(net.socialInsurance.pensionCents, 558000);
      expect(net.socialInsurance.unempCents, 78000);
    });

    test('net income', () {
      expect(net.netYearCents, 3762200);
      expect(net.netMonthCents, 313517);
    });

    test('ALG 1 (24 insured months)', () {
      final alg = alg1Benefit(
        grossYearCents: eur(60000),
        taxClass: TaxClass.i,
        age: 30,
      );
      expect(alg.assessedGrossDayCents, 16438);
      expect(alg.benefitBaseDayCents, 10595);
      expect(alg.benefitDayCents, 6357);
      expect(alg.benefitMonthCents, 190710);
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
      expect(net.taxes.taxableCents, 7300400);
      expect(net.taxes.vorsorgepauschaleCents, 1573000);
      expect(net.taxes.wageTaxCents, 1224600);
      expect(net.taxes.soliCents, 0,
          reason: 'assessment basis below the doubled exemption limit');
      expect(net.taxes.churchTaxCents, 84222);
      expect(net.socialInsurance.healthCents, 610313, reason: 'health capped at ceiling');
      expect(net.socialInsurance.careCents, 125550, reason: 'care 1.8 %, 1 child');
      expect(net.socialInsurance.pensionCents, 837000);
      expect(net.socialInsurance.unempCents, 117000);
    });

    test('net income', () {
      expect(net.netYearCents, 6001315);
      expect(net.netMonthCents, 500110);
    });

    test('ALG 1 with the increased 67 % rate', () {
      final alg = alg1Benefit(
        grossYearCents: eur(90000),
        taxClass: TaxClass.iii,
        age: 40,
        hasChild: true,
        childAllowanceFactor: 1,
        totalChildren: 1,
        childrenUnder25: 1,
      );
      expect(alg.benefitBaseDayCents, 16370);
      expect(alg.benefitDayCents, 10967);
      expect(alg.benefitMonthCents, 329010);
    });
  });

  group('Golden G3 – 130,000 €, class I, childless, 45 (above both ceilings)', () {
    final net = annualNetIncome(
      grossYearCents: eur(130000),
      taxClass: TaxClass.i,
      age: 45,
    );

    test('taxes and social insurance', () {
      expect(net.taxes.taxableCents, 11152500);
      expect(net.taxes.vorsorgepauschaleCents, 1720900);
      expect(net.taxes.wageTaxCents, 3570400);
      expect(net.taxes.soliCents, 182712, reason: 'taper zone still applies');
      expect(net.socialInsurance.healthCents, 610313);
      expect(net.socialInsurance.careCents, 167400);
      expect(net.socialInsurance.pensionCents, 943020, reason: 'pension capped at ceiling');
      expect(net.socialInsurance.unempCents, 131820);
    });

    test('net income', () {
      expect(net.netYearCents, 7394335);
      expect(net.netMonthCents, 616195);
    });

    test('ALG 1: assessment wage capped at the ceiling → maximum benefit', () {
      final alg = alg1Benefit(
        grossYearCents: eur(130000),
        taxClass: TaxClass.i,
        age: 45,
      );
      expect(alg.assessedGrossYearCents, eur(101400));
      expect(alg.wageTaxYearCents, 2369200);
      expect(alg.soliYearCents, 39769);
      expect(alg.benefitBaseDayCents, 15624);
      expect(alg.benefitDayCents, 9374);
      expect(alg.benefitMonthCents, 281220);
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
      expect(net.taxes.taxableCents, 5957300);
      expect(net.taxes.vorsorgepauschaleCents, 1416100);
      expect(net.taxes.wageTaxCents, 1406800);
      expect(net.taxes.soliCents, 0,
          reason: 'below the exemption limit with 2 child allowances');
      expect(net.socialInsurance.careCents, 108113,
          reason: 'care 1.55 % (discount for the 2nd child), capped at ceiling');
      expect(net.socialInsurance.totalCents, 1513426);
    });

    test('net income', () {
      expect(net.netYearCents, 4579774);
      expect(net.netMonthCents, 381648);
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
      expect(net.taxes.taxableCents, 3491300);
      expect(net.taxes.vorsorgepauschaleCents, 882100);
      expect(net.taxes.wageTaxCents, 1043800, reason: '§ 39b Abs. 2 S. 7 (class V)');
      expect(net.taxes.soliCents, 0);
      expect(net.taxes.churchTaxCents, 20224,
          reason: '8 % on the notional wage tax with 2 child allowances');
      expect(net.socialInsurance.totalCents, 940500);
    });

    test('net income', () {
      expect(net.netYearCents, 2495476);
      expect(net.netMonthCents, 207956);
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
      expect(alg.wageTaxYearCents, 1364400);
      expect(alg.benefitBaseDayCents, 17083);
      expect(alg.benefitDayCents, 11445);
      expect(alg.benefitMonthCents, 343350);
      expect(alg1EntitlementDays(insuredMonths: 48, age: 58), 720);
    });

    test('blocking period after a termination agreement: half a year of ALG lost', () {
      final s = blockingPeriodSimulation(entitlementDays: 720, benefitDayCents: 11445);
      expect(s.blockingDays, 84);
      expect(s.reductionDays, 180, reason: 'one quarter of 720 days');
      expect(s.remainingEntitlementDays, 540);
      expect(s.lostBenefitCents, 2060100, reason: '180 × 114.45 € = 20,601 €');
    });
  });

  group('Golden G8 – ALG + § 158: 80,000 €, class I, 50, severance 60,000 €', () {
    final alg = alg1Benefit(
      grossYearCents: eur(80000),
      taxClass: TaxClass.i,
      age: 50,
    );

    test('assessment and entitlement duration (30 months, age 50 → 450 days)', () {
      expect(alg.benefitBaseDayCents, 13257);
      expect(alg.benefitDayCents, 7954);
      expect(alg.benefitMonthCents, 238620);
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
