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
  /// Section thresholds are not applied, and the result is not rounded
  /// (section 288B requires TDS to be rounded to the nearest rupee; use
  /// `RoundingHelper.roundToNearest`).
  ///
  /// Throws an [ArgumentError] if [amount] is not finite or [rate] is not
  /// between 0 and 100.
  static TdsResult calculate({
    required double amount,
    required double rate,
  }) {
    checkFinite(amount, 'amount');
    checkRate(rate, 'rate', max: 100);

    final tds = amount * rate / 100;

    return TdsResult(
      tds: tds,
      netAmount: amount - tds,
    );
  }
}
