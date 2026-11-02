/// Splitting a tax amount into GST components, shared by the GST
/// calculators. Not exported.
library;

import '../models/gst_result.dart';
import 'rounding.dart';

/// Splits [tax] into CGST and SGST halves or IGST, optionally rounding the
/// components to paise so that they add up. [tax] must be finite and not
/// negative zero. Used by `GstCalculator` and `GstSplit`.
GstResult splitTax(
  double tax, {
  required bool intraState,
  required bool roundToPaise,
}) {
  if (intraState) {
    // Adding 0.0 turns -0.0 (from halving the smallest negative double)
    // into 0.0. The rounded half is never -0.0, so neither is its double.
    final half =
        roundToPaise ? roundHalfAwayFromZero(tax / 2, 2) : tax / 2 + 0.0;
    return GstResult(
      cgst: half,
      sgst: half,
      igst: 0,
      totalTax: roundToPaise ? half * 2 : tax,
    );
  }
  final igst = roundToPaise ? roundHalfAwayFromZero(tax, 2) : tax;
  return GstResult(cgst: 0, sgst: 0, igst: igst, totalTax: igst);
}
