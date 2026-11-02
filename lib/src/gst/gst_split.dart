/// Splitting a known GST amount into CGST/SGST or IGST.
library;

import '../models/gst_result.dart';
import '../internal/checks.dart';
import '../internal/gst_components.dart';

/// Splits an already-calculated GST amount into its components.
abstract final class GstSplit {
  /// Splits [totalTax] into CGST and SGST (half each) when [intraState] is
  /// `true`, or assigns it entirely to IGST otherwise.
  ///
  /// By default results are not rounded. Set [roundToPaise] to `true` to get
  /// paise amounts that add up: CGST and SGST are each half of [totalTax]
  /// rounded to paise, and the result's `totalTax` is their sum; IGST is
  /// [totalTax] rounded to paise. For an MRP of ₹10 inclusive of 18% GST,
  /// the tax is 1.5254...:
  ///
  /// ```dart
  /// final tax = GstInclusiveCalculator.extractGST(amount: 10, rate: 18)['tax']!;
  /// final gst = GstSplit.split(totalTax: tax, intraState: true, roundToPaise: true);
  /// // gst.cgst == 0.76, gst.sgst == 0.76, gst.totalTax == 1.52
  /// // The printed taxable value is then 10 - gst.totalTax == 8.48.
  /// ```
  ///
  /// For a tax-inclusive price, print `amount - totalTax` as the taxable
  /// value, so that the lines add up to the price.
  ///
  /// An intra-state [totalTax] that is already rounded to an odd number of
  /// paise cannot be split into equal paise halves: 0.05 gives CGST and SGST
  /// of 0.03 each and a `totalTax` of 0.06. Where you have the taxable value,
  /// use `GstCalculator.calculate` with `roundToPaise: true` instead.
  ///
  /// Throws an [ArgumentError] if [totalTax] is not finite.
  static GstResult split({
    required double totalTax,
    required bool intraState,
    bool roundToPaise = false,
  }) {
    checkFinite(totalTax, 'totalTax');
    // Adding 0.0 turns -0.0 into 0.0.
    final tax = totalTax + 0.0;

    return splitTax(tax, intraState: intraState, roundToPaise: roundToPaise);
  }
}
