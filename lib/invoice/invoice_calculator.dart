import '../models/invoice_result.dart';
import '../rounding/rounding_helper.dart';

class InvoiceCalculator {
  static InvoiceResult calculate({
    required double subtotal,
    double discount = 0,
    double gstRate = 18,
  }) {
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
}
