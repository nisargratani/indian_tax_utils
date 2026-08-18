/// Utility library for GST calculation.
library gst_calculator;

import '../models/gst_result.dart';

/// A utility class for calculating GST components.
class GstCalculator {
  /// Default constructor.
  GstCalculator();

  /// Calculates CGST, SGST, IGST and Total Tax for a given amount and rate.
  static GstResult calculate({
    required double amount,
    required double rate,
    required bool intraState,
  }) {
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
