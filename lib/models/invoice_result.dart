class InvoiceResult {
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final double roundedTotal;

  InvoiceResult({
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.roundedTotal,
  });

  @override
  String toString() {
    return 'InvoiceResult(subtotal: $subtotal, discount: $discount, tax: $tax, total: $total, roundedTotal: $roundedTotal)';
  }
}
