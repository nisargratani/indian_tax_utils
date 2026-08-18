/// Utility library for invoice result model.
library invoice_result;

/// Model class representing the result of an invoice calculation.
class InvoiceResult {
  /// The subtotal amount.
  final double subtotal;
  /// The discount amount.
  final double discount;
  /// The tax amount.
  final double tax;
  /// The total amount.
  final double total;
  /// The rounded total amount.
  final double roundedTotal;

  /// Creates an [InvoiceResult] instance.
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
