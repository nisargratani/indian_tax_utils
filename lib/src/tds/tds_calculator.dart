/// TDS (Tax Deducted at Source) calculation.
library;

import '../models/tds_result.dart';
import '../internal/checks.dart';

/// Calculates TDS (Tax Deducted at Source).
abstract final class TdsCalculator {
  /// Calculates TDS on [amount] at [rate] percent.
  ///
  /// [TdsResult.tds] is the tax deducted and [TdsResult.netAmount] is the
  /// amount payable after deduction (`amount - tds`).
  ///
  /// ```dart
  /// final r = TdsCalculator.calculate(amount: 10000, rate: 10);
  /// // r.tds == 1000, r.netAmount == 9000
  /// ```
  ///
  /// Section thresholds are not applied, and the result is not rounded. TDS
  /// is commonly rounded to the nearest rupee in TDS returns and challans;
  /// round it as your compliance process requires, for example with
  /// `RoundingHelper.roundToNearest`.
  ///
  /// Throws an [ArgumentError] if [amount] is not finite, if [rate] is not
  /// between 0 and 100, or if the result is not finite (an [amount] so large
  /// that the calculation overflows).
  static TdsResult calculate({
    required double amount,
    required double rate,
  }) {
    checkFinite(amount, 'amount');
    checkRate(rate, 'rate', max: 100);

    // Adding 0.0 turns -0.0 (e.g. -100 at 0%) into 0.0.
    final tds = amount * rate / 100 + 0.0;
    final netAmount = amount - tds + 0.0;
    checkResult(tds, amount, 'amount');
    checkResult(netAmount, amount, 'amount');

    return TdsResult(
      tds: tds,
      netAmount: netAmount,
    );
  }
}
