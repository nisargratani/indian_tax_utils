import 'package:test/test.dart';
import 'package:indian_tax_utils/indian_tax_utils.dart';

void main() {
  group('InvoiceCalculator', () {
    test("Invoice total with discount and GST", () {
      final result = InvoiceCalculator.calculate(
        subtotal: 5000,
        discount: 200,
        gstRate: 18,
      );

      // (5000 - 200) * 1.18 = 4800 * 1.18 = 5664
      expect(result.tax, 864);
      expect(result.total, 5664);
      expect(result.roundedTotal, 5664);
    });

    test("Invoice rounding", () {
      final result = InvoiceCalculator.calculate(
        subtotal: 100,
        discount: 0,
        gstRate: 17.5,
      );

      // 100 * 1.175 = 117.5
      expect(result.total, 117.5);
      expect(result.roundedTotal, 118);
    });
  });

  group('InvoiceItem', () {
    test("Invoice item calculations", () {
      final item = InvoiceItem(
        description: "Test Item",
        quantity: 2,
        unitPrice: 500,
        taxRate: 18,
        discount: 50,
      );

      expect(item.subtotal, 1000);
      expect(item.taxableAmount, 950);
      expect(item.taxAmount, 171);
      expect(item.total, 1121);
    });
  });
}
