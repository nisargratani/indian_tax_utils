/// Utility library for GST split calculation.
library gst_split;

import '../models/gst_result.dart';

/// A utility class for splitting a total tax amount into GST components.
class GstSplit {
  /// Default constructor.
  GstSplit();

  /// Splits a total tax amount into CGST, SGST, or IGST based on intra/inter state.
  static GstResult split({
    required double totalTax,
    required bool intraState,
  }) {
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
