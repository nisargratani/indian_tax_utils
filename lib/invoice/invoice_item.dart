/// Utility library for invoice item model.
library invoice_item;

/// Model class representing an item in an invoice.
class InvoiceItem {
  /// The description of the item.
  final String description;
  /// The quantity of the item.
  final double quantity;
  /// The unit price of the item.
  final double unitPrice;
  /// The tax rate for the item.
  final double taxRate;
  /// The discount applied to the item.
  final double discount;

  /// Creates an [InvoiceItem] instance.
  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.taxRate = 18,
    this.discount = 0,
  });

  /// Gets the subtotal.
  double get subtotal => quantity * unitPrice;
  /// Gets the taxable amount.
  double get taxableAmount => subtotal - discount;
  /// Gets the tax amount.
  double get taxAmount => taxableAmount * taxRate / 100;
  /// Gets the total amount.
  double get total => taxableAmount + taxAmount;
}
