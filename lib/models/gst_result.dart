class GstResult {
  final double cgst;
  final double sgst;
  final double igst;
  final double totalTax;

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
