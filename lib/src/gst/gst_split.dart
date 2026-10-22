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
    // Adding 0.0 turns -0.0 into 0.0.
    final tax = totalTax + 0.0;

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
