/// M8 – Severance payout timing ("dieses Jahr oder nächstes Jahr?").
///
/// The tax on a severance depends on the *other* taxable income of the payout
/// year: with the progressive tariff and the Fünftelregelung (§ 34 EStG),
/// moving the payout into a low-income year (e.g. a year of unemployment)
/// usually lowers the tax on the severance. This compares the **net**
/// severance for two candidate payout years. All amounts are `int` cents.
///
/// Orientation only – the actual optimum depends on the full assessment of
/// both years (other income, deductions, joint assessment) and should be
/// checked by a tax adviser.
library;

import 'dart:math';

import 'm3_severance.dart';
import 'params.dart';

/// Net outcome of paying the severance in one particular year.
class SeveranceTimingOption {
  const SeveranceTimingOption({
    required this.otherTaxableIncomeCents,
    required this.taxOnSeveranceCents,
    required this.netSeveranceCents,
    required this.fifthRuleUsed,
  });

  /// The year's other taxable income (without the severance).
  final int otherTaxableIncomeCents;

  /// Effective tax on the severance, i.e. the better of regular taxation and
  /// the Fünftelregelung (the assessment applies § 34 only when beneficial).
  final int taxOnSeveranceCents;

  /// Severance minus [taxOnSeveranceCents].
  final int netSeveranceCents;

  /// Whether the Fünftelregelung is the better method in this year.
  final bool fifthRuleUsed;
}

/// Comparison of paying the severance this year vs. next year.
class SeveranceTimingComparison {
  const SeveranceTimingComparison({
    required this.severanceCents,
    required this.thisYear,
    required this.nextYear,
  });

  final int severanceCents;
  final SeveranceTimingOption thisYear;
  final SeveranceTimingOption nextYear;

  /// Net gain of taking the payout next year instead of this year
  /// (positive → next year keeps more, negative → this year is better).
  int get gainNextYearCents =>
      nextYear.netSeveranceCents - thisYear.netSeveranceCents;

  /// Whether next year yields a strictly higher net severance.
  bool get nextYearBetter => gainNextYearCents > 0;

  /// Absolute difference between the two timings.
  int get differenceCents => gainNextYearCents.abs();
}

SeveranceTimingOption _option({
  required int severanceCents,
  required int otherTaxableIncomeCents,
  required bool splitting,
  required ExitParams params,
}) {
  final c = severanceComparison(
    taxableIncomeWithoutSeveranceCents: otherTaxableIncomeCents,
    severanceCents: severanceCents,
    splitting: splitting,
    params: params,
  );
  final regular = c.taxOnSeveranceRegularCents;
  final fifth = c.taxOnSeveranceFifthRuleCents;
  final effectiveTax = min(regular, fifth);
  return SeveranceTimingOption(
    otherTaxableIncomeCents: otherTaxableIncomeCents,
    taxOnSeveranceCents: effectiveTax,
    netSeveranceCents: severanceCents - effectiveTax,
    fifthRuleUsed: fifth < regular,
  );
}

/// Compares the net severance when paid this year (other taxable income
/// [taxableIncomeThisYearCents]) vs. next year ([taxableIncomeNextYearCents]).
SeveranceTimingComparison compareSeveranceTiming({
  required int severanceCents,
  required int taxableIncomeThisYearCents,
  required int taxableIncomeNextYearCents,
  bool splitting = false,
  ExitParams? params,
}) {
  assert(severanceCents >= 0);
  final p = params ?? ExitParams.year2026();
  return SeveranceTimingComparison(
    severanceCents: severanceCents,
    thisYear: _option(
      severanceCents: severanceCents,
      otherTaxableIncomeCents: taxableIncomeThisYearCents,
      splitting: splitting,
      params: p,
    ),
    nextYear: _option(
      severanceCents: severanceCents,
      otherTaxableIncomeCents: taxableIncomeNextYearCents,
      splitting: splitting,
      params: p,
    ),
  );
}
