/// Invoice line item.
library;

/// A single line on an invoice.
///
/// Pass a list of these to `InvoiceCalculator.fromItems` to total an invoice
/// with mixed GST rates.
class InvoiceItem {
  /// A description of the goods or service.
  final String description;

  /// The number of units.
  final double quantity;

  /// The price of one unit, excluding GST.
  final double unitPrice;

  /// The GST rate for this line, as a percentage (default 18).
  final double taxRate;

  /// A flat discount on the whole line (not per unit), applied before tax.
  final double discount;

  /// Creates an [InvoiceItem]. Values are validated when the item is passed
  /// to `InvoiceCalculator.fromItems`.
  const InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.taxRate = 18,
    this.discount = 0,
  });

  /// `quantity * unitPrice`, before discount and tax.
  double get subtotal => quantity * unitPrice;

  /// [subtotal] minus [discount]: the value GST is charged on.
  double get taxableAmount => subtotal - discount;

  /// GST on [taxableAmount] at [taxRate].
  double get taxAmount => taxableAmount * taxRate / 100;

  /// [taxableAmount] plus [taxAmount].
  double get total => taxableAmount + taxAmount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceItem &&
          other.description == description &&
          other.quantity == quantity &&
          other.unitPrice == unitPrice &&
          other.taxRate == taxRate &&
          other.discount == discount;

  @override
  int get hashCode =>
      Object.hash(description, quantity, unitPrice, taxRate, discount);

  @override
  String toString() {
    return 'InvoiceItem(description: $description, quantity: $quantity, unitPrice: $unitPrice, taxRate: $taxRate, discount: $discount)';
  }
}
