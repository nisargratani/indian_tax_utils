/// Invoice total calculation.
library;

import '../models/invoice_result.dart';
import '../rounding/rounding_helper.dart';
import '../internal/checks.dart';
import 'invoice_item.dart';

/// Calculates invoice totals: discount, GST, grand total and rounded total.
abstract final class InvoiceCalculator {
  /// Calculates an invoice taxed at a single [gstRate] percent (default 18).
  ///
  /// The [discount] is applied before tax, so
  /// `tax = (subtotal - discount) * gstRate / 100` and
  /// `total = subtotal - discount + tax`. The rounded total is the total
  /// rounded to the nearest rupee.
  ///
  /// ```dart
  /// final r = InvoiceCalculator.calculate(subtotal: 5000, discount: 200);
  /// // r.tax == 864, r.total == 5664
  /// ```
  ///
  /// Throws an [ArgumentError] if any value is not finite, if [gstRate] is
  /// negative, or if [discount] is negative or greater than [subtotal].
  static InvoiceResult calculate({
    required double subtotal,
    double discount = 0,
    double gstRate = 18,
  }) {
    checkFinite(subtotal, 'subtotal');
    checkDiscount(discount, subtotal, 'discount');
    checkRate(gstRate, 'gstRate');

    final taxable = subtotal - discount;
    final tax = taxable * gstRate / 100;

    final total = taxable + tax;
    final rounded = RoundingHelper.roundToNearest(total);

    return InvoiceResult(
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
      roundedTotal: rounded,
    );
  }

  /// Calculates an invoice from line [items], each with its own quantity,
  /// discount and GST rate.
  ///
  /// The result's `subtotal`, `discount`, `tax` and `total` are the sums of
  /// the corresponding [InvoiceItem] values; `roundedTotal` is the total
  /// rounded to the nearest rupee. An empty list gives an all-zero result.
  ///
  /// ```dart
  /// final r = InvoiceCalculator.fromItems([
  ///   InvoiceItem(description: 'Rice', quantity: 10, unitPrice: 60, taxRate: 5),
  ///   InvoiceItem(description: 'Soap', quantity: 3, unitPrice: 45, taxRate: 18),
  /// ]);
  /// // r.subtotal == 735, r.tax == 54.3, r.total == 789.3
  /// ```
  ///
  /// Per-line tax is not rounded; round each [InvoiceItem.taxAmount] with
  /// `RoundingHelper.roundTo` first if your invoices round tax per line.
  ///
  /// Throws an [ArgumentError] if any item has a non-finite quantity or unit
  /// price, a negative or non-finite tax rate, or a discount that is negative
  /// or greater than the item's subtotal.
  static InvoiceResult fromItems(List<InvoiceItem> items) {
    var subtotal = 0.0;
    var discount = 0.0;
    var tax = 0.0;

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      checkFinite(item.quantity, 'items[$i].quantity');
      checkFinite(item.unitPrice, 'items[$i].unitPrice');
      checkRate(item.taxRate, 'items[$i].taxRate');
      checkDiscount(item.discount, item.subtotal, 'items[$i].discount');

      subtotal += item.subtotal;
      discount += item.discount;
      tax += item.taxAmount;
    }

    final total = subtotal - discount + tax;

    return InvoiceResult(
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
      roundedTotal: RoundingHelper.roundToNearest(total),
    );
  }
}
