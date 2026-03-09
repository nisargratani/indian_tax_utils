class InvoiceItem {
  final String description;
  final double quantity;
  final double unitPrice;
  final double taxRate;
  final double discount;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.taxRate = 18,
    this.discount = 0,
  });

  double get subtotal => quantity * unitPrice;
  double get taxableAmount => subtotal - discount;
  double get taxAmount => taxableAmount * taxRate / 100;
  double get total => taxableAmount + taxAmount;
}
