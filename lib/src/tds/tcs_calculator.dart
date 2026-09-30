/// TCS (Tax Collected at Source) calculation.
library;

import '../models/tds_result.dart';
import '../internal/checks.dart';

/// Calculates TCS (Tax Collected at Source).
abstract final class TcsCalculator {
  /// Calculates TCS on [amount] at [rate] percent.
  ///
  /// TCS is collected on top of the invoice value, so in the returned
  /// [TdsResult], `tds` holds the **TCS amount** and `netAmount` is the
  /// amount receivable (`amount + tcs`).
  ///
  /// ```dart
  /// final r = TcsCalculator.calculate(amount: 10000, rate: 0.1);
  /// // r.tds == 10 (the TCS), r.netAmount == 10010
  /// ```
  ///
  /// The result is not rounded.
  ///
  /// Throws an [ArgumentError] if [amount] is not finite or [rate] is not
  /// between 0 and 100.
  static TdsResult calculate({
    required double amount,
    required double rate,
  }) {
    checkFinite(amount, 'amount');
    checkRate(rate, 'rate', max: 100);

    final tcs = amount * rate / 100;

    return TdsResult(
      tds: tcs,
      netAmount: amount + tcs,
    );
  }
}
