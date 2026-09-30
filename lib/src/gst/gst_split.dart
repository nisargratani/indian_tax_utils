/// Splitting a known GST amount into CGST/SGST or IGST.
library;

import '../models/gst_result.dart';
import '../internal/checks.dart';

/// Splits an already-calculated GST amount into its components.
abstract final class GstSplit {
  /// Splits [totalTax] into CGST and SGST (half each) when [intraState] is
  /// `true`, or assigns it entirely to IGST otherwise.
  ///
  /// Throws an [ArgumentError] if [totalTax] is not finite.
  static GstResult split({
    required double totalTax,
    required bool intraState,
  }) {
    checkFinite(totalTax, 'totalTax');

    if (intraState) {
      return GstResult(
        cgst: totalTax / 2,
        sgst: totalTax / 2,
        igst: 0,
        totalTax: totalTax,
      );
    } else {
      return GstResult(
        cgst: 0,
        sgst: 0,
        igst: totalTax,
        totalTax: totalTax,
      );
    }
  }
}
