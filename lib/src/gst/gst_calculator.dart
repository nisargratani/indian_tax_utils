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
  /// Throws an [ArgumentError] if [amount] is not finite or [rate] is negative
  /// or not finite.
  static GstResult calculate({
    required double amount,
    required double rate,
    required bool intraState,
  }) {
    checkFinite(amount, 'amount');
    checkRate(rate, 'rate');

    final tax = amount * rate / 100;

    if (intraState) {
      return GstResult(
        cgst: tax / 2,
        sgst: tax / 2,
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
