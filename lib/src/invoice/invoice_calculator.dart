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
  /// negative, if [discount] is negative or greater than [subtotal], or if
  /// the result is not finite (a [subtotal] so large that the calculation
  /// overflows).
  static InvoiceResult calculate({
    required double subtotal,
    double discount = 0,
    double gstRate = 18,
  }) {
    checkFinite(subtotal, 'subtotal');
    checkDiscount(discount, subtotal, 'discount');
    checkRate(gstRate, 'gstRate');

    // Adding 0.0 turns -0.0 (e.g. -100 at 0%) into 0.0.
    final taxable = subtotal - discount + 0.0;
    final tax = taxable * gstRate / 100 + 0.0;

    final total = taxable + tax;
    checkResult(tax, subtotal, 'subtotal');
    checkResult(total, subtotal, 'subtotal');
    final rounded = RoundingHelper.roundToNearest(total);

    return InvoiceResult(
      subtotal: subtotal + 0.0,
      discount: discount + 0.0,
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
  /// price, a negative or non-finite tax rate, a discount that is negative
  /// or greater than the item's subtotal, or values so large that the item's
  /// or the invoice's totals are not finite.
  static InvoiceResult fromItems(List<InvoiceItem> items) {
    var subtotal = 0.0;
    var discount = 0.0;
    var tax = 0.0;

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      checkFinite(item.quantity, 'items[$i].quantity');
      checkFinite(item.unitPrice, 'items[$i].unitPrice');
      checkRate(item.taxRate, 'items[$i].taxRate');
      checkResult(item.subtotal, item.quantity, 'items[$i].quantity');
      checkDiscount(item.discount, item.subtotal, 'items[$i].discount');
      checkResult(item.total, item.quantity, 'items[$i].quantity');

      subtotal += item.subtotal;
      discount += item.discount;
      tax += item.taxAmount;
    }

    final total = subtotal - discount + tax;
    if (!subtotal.isFinite || !tax.isFinite || !total.isFinite) {
      throw ArgumentError('Result is not finite', 'items');
    }

    return InvoiceResult(
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
      roundedTotal: RoundingHelper.roundToNearest(total),
    );
  }
}
