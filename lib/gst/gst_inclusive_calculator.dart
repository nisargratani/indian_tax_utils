class GstInclusiveCalculator {
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
