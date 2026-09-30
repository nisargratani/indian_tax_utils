/// GST calculation result.
library;

/// The GST components of a supply.
///
/// For intra-state supplies [cgst] and [sgst] each hold half of [totalTax]
/// and [igst] is zero; for inter-state supplies [igst] equals [totalTax].
class GstResult {
  /// Central GST.
  final double cgst;

  /// State (or Union Territory) GST.
  final double sgst;

  /// Integrated GST, charged on inter-state supplies.
  final double igst;

  /// Total GST: `cgst + sgst + igst`.
  final double totalTax;

  /// Creates a [GstResult].
  const GstResult({
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.totalTax,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GstResult &&
          other.cgst == cgst &&
          other.sgst == sgst &&
          other.igst == igst &&
          other.totalTax == totalTax;

  @override
  int get hashCode => Object.hash(cgst, sgst, igst, totalTax);

  @override
  String toString() {
    return 'GstResult(cgst: $cgst, sgst: $sgst, igst: $igst, totalTax: $totalTax)';
  }
}
