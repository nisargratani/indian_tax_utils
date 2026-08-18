/// Utility library for GST result model.
library gst_result;

/// Model class representing the result of a GST calculation.
class GstResult {
  /// The Central Goods and Services Tax amount.
  final double cgst;
  /// The State Goods and Services Tax amount.
  final double sgst;
  /// The Integrated Goods and Services Tax amount.
  final double igst;
  /// The total tax amount.
  final double totalTax;

  /// Creates a [GstResult] instance.
  GstResult({
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.totalTax,
  });

  @override
  String toString() {
    return 'GstResult(cgst: $cgst, sgst: $sgst, igst: $igst, totalTax: $totalTax)';
  }
}
