/// GST calculation on a tax-exclusive amount.
library;

import '../models/gst_result.dart';
import '../internal/checks.dart';

/// Calculates GST on a tax-exclusive (base) amount.
abstract final class GstCalculator {
  /// Calculates GST on [amount] at [rate] percent.
  ///
  /// For an intra-state supply ([intraState] `true`) the tax is split equally
  /// into CGST and SGST; for an inter-state supply it is charged entirely as
  /// IGST.
  ///
  /// ```dart
  /// final gst = GstCalculator.calculate(amount: 1000, rate: 18, intraState: true);
  /// // gst.cgst == 90, gst.sgst == 90, gst.totalTax == 180
  /// ```
  ///
  /// Results are not rounded; use `RoundingHelper.roundTo` if you need values
  /// in whole paise. [amount] may be negative (for example on a credit note).
  ///
  /// Throws an [ArgumentError] if [amount] is not finite, if [rate] is
  /// negative or not finite, or if the result is not finite (an [amount] so
  /// large that the calculation overflows).
  static GstResult calculate({
    required double amount,
    required double rate,
    required bool intraState,
  }) {
    checkFinite(amount, 'amount');
    checkRate(rate, 'rate');

    // Adding 0.0 turns -0.0 (e.g. -100 at 0%) into 0.0.
    final tax = amount * rate / 100 + 0.0;
    checkResult(tax, amount, 'amount');

    if (intraState) {
      final half = tax / 2 + 0.0;
      return GstResult(
        cgst: half,
        sgst: half,
        igst: 0,
        totalTax: tax,
      );
    } else {
      return GstResult(
        cgst: 0,
        sgst: 0,
        igst: tax,
        totalTax: tax,
      );
    }
  }
}
