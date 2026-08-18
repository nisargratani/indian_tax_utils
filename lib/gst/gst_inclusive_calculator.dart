/// Utility library for GST inclusive calculation.
library gst_inclusive_calculator;

/// A utility class for extracting GST from an inclusive amount.
class GstInclusiveCalculator {
  /// Default constructor.
  GstInclusiveCalculator();

  /// Extracts the base amount and tax from a GST inclusive amount.
  static Map<String, double> extractGST({
    required double amount,
    required double rate,
  }) {
    final base = amount / (1 + rate / 100);
    final tax = amount - base;

    return {
      "base": base,
      "tax": tax,
    };
  }
}
