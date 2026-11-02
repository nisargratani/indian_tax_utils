/// GST calculation on a tax-exclusive amount.
library;

import '../models/gst_result.dart';
import '../internal/checks.dart';
import '../internal/gst_components.dart';

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
  /// By default results are not rounded. Rounding the components yourself
  /// can break the invoice: on 10.25 at 18%, CGST and SGST are 0.9225 each
  /// (0.92 + 0.92 = 1.84) but the total is 1.845 (1.85). Set [roundToPaise]
  /// to `true` to get paise amounts that add up. CGST and SGST are separate
  /// levies at half the rate each, so each is rounded to paise and
  /// `totalTax` is their sum; IGST is rounded to paise and equals
  /// `totalTax`:
  ///
  /// ```dart
  /// GstCalculator.calculate(
  ///     amount: 10.25, rate: 18, intraState: true, roundToPaise: true);
  /// // cgst 0.92, sgst 0.92, totalTax 1.84
  /// GstCalculator.calculate(
  ///     amount: 10.25, rate: 18, intraState: false, roundToPaise: true);
  /// // igst 1.85, totalTax 1.85
  /// ```
  ///
  /// [amount] may be negative (for example on a credit note).
  ///
  /// Throws an [ArgumentError] if [amount] is not finite, if [rate] is
  /// negative or not finite, or if the result is not finite (an [amount] so
  /// large that the calculation overflows).
  static GstResult calculate({
    required double amount,
    required double rate,
    required bool intraState,
    bool roundToPaise = false,
  }) {
    checkFinite(amount, 'amount');
    checkRate(rate, 'rate');

    // Adding 0.0 turns -0.0 (e.g. -100 at 0%) into 0.0.
    final tax = amount * rate / 100 + 0.0;
    checkResult(tax, amount, 'amount');

    return splitTax(tax, intraState: intraState, roundToPaise: roundToPaise);
  }
}
