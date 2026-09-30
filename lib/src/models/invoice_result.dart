/// Invoice calculation result.
library;

import '../internal/rounding.dart';

/// The totals of an invoice.
class InvoiceResult {
  /// The sum of line values before discount and tax.
  final double subtotal;

  /// The total discount applied before tax.
  final double discount;

  /// The total GST charged.
  final double tax;

  /// The grand total: `subtotal - discount + tax`, unrounded.
  final double total;

  /// [total] rounded to the nearest rupee.
  final double roundedTotal;

  /// Creates an [InvoiceResult].
  const InvoiceResult({
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.roundedTotal,
  });

  /// The "round off" line printed on invoices: `roundedTotal - total`,
  /// rounded to paise. Positive when the total was rounded up.
  double get roundOff => roundHalfAwayFromZero(roundedTotal - total, 2);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceResult &&
          other.subtotal == subtotal &&
          other.discount == discount &&
          other.tax == tax &&
          other.total == total &&
          other.roundedTotal == roundedTotal;

  @override
  int get hashCode => Object.hash(subtotal, discount, tax, total, roundedTotal);

  @override
  String toString() {
    return 'InvoiceResult(subtotal: $subtotal, discount: $discount, tax: $tax, total: $total, roundedTotal: $roundedTotal)';
  }
}
