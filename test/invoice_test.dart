import 'package:indian_tax_utils/indian_tax_utils.dart';
import 'package:test/test.dart';

void main() {
  group('InvoiceCalculator', () {
    test('Invoice total with discount and GST', () {
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

    test('Invoice rounding', () {
      final result = InvoiceCalculator.calculate(
        subtotal: 100,
        discount: 0,
        gstRate: 17.5,
      );

      // 100 * 1.175 = 117.5
      expect(result.total, 117.5);
      expect(result.roundedTotal, 118);
    });

    test('defaults to no discount and 18% GST', () {
      final result = InvoiceCalculator.calculate(subtotal: 1000);
      expect(result.discount, 0);
      expect(result.tax, 180);
      expect(result.total, 1180);
    });

    test('roundOff is the rounding adjustment in paise', () {
      expect(
        InvoiceCalculator.calculate(subtotal: 100, gstRate: 17.5).roundOff,
        0.5,
      );
      // 99.99 * 1.18 = 117.9882 -> 118
      expect(
        InvoiceCalculator.calculate(subtotal: 99.99).roundOff,
        0.01,
      );
      // 10.3 * 1.18 = 12.154 -> 12
      expect(
        InvoiceCalculator.calculate(subtotal: 10.3).roundOff,
        -0.15,
      );
      expect(InvoiceCalculator.calculate(subtotal: 1000).roundOff, 0);
    });

    test('negative subtotal without discount is allowed (credit note)', () {
      final result = InvoiceCalculator.calculate(subtotal: -1000);
      expect(result.total, -1180);
      expect(result.roundedTotal, -1180);
    });

    test('rejects invalid input', () {
      expect(
        () => InvoiceCalculator.calculate(subtotal: 100, discount: 200),
        throwsArgumentError,
      );
      expect(
        () => InvoiceCalculator.calculate(subtotal: 100, discount: -1),
        throwsArgumentError,
      );
      expect(
        () => InvoiceCalculator.calculate(subtotal: double.nan),
        throwsArgumentError,
      );
      expect(
        () => InvoiceCalculator.calculate(subtotal: 100, gstRate: -18),
        throwsArgumentError,
      );
    });

    test('error messages name the offending argument', () {
      expect(
        () => InvoiceCalculator.calculate(subtotal: 100, discount: 200),
        throwsA(isA<ArgumentError>()
            .having((e) => e.name, 'name', 'discount')
            .having((e) => e.message, 'message', contains('exceed'))),
      );
    });
  });

  group('InvoiceCalculator.fromItems', () {
    test('sums mixed-rate items', () {
      final result = InvoiceCalculator.fromItems([
        InvoiceItem(
            description: 'Rice', quantity: 10, unitPrice: 60, taxRate: 5),
        InvoiceItem(
            description: 'Soap', quantity: 3, unitPrice: 45, taxRate: 18),
        InvoiceItem(
          description: 'Oil',
          quantity: 1,
          unitPrice: 200,
          taxRate: 5,
          discount: 20,
        ),
      ]);

      // Rice: 600 + 30; Soap: 135 + 24.3; Oil: 180 + 9
      expect(result.subtotal, 935);
      expect(result.discount, 20);
      expect(result.tax, closeTo(63.3, 1e-9));
      expect(result.total, closeTo(978.3, 1e-9));
      expect(result.roundedTotal, 978);
      expect(result.roundOff, -0.3);
    });

    test('matches calculate() for a single item', () {
      final fromItems = InvoiceCalculator.fromItems([
        InvoiceItem(
          description: 'Service',
          quantity: 1,
          unitPrice: 5000,
          discount: 200,
        ),
      ]);
      final single = InvoiceCalculator.calculate(subtotal: 5000, discount: 200);
      expect(fromItems.tax, single.tax);
      expect(fromItems.total, single.total);
      expect(fromItems.roundedTotal, single.roundedTotal);
    });

    test('empty list gives zero totals', () {
      final result = InvoiceCalculator.fromItems([]);
      expect(result.subtotal, 0);
      expect(result.tax, 0);
      expect(result.total, 0);
      expect(result.roundedTotal, 0);
    });

    test('reports which item is invalid', () {
      expect(
        () => InvoiceCalculator.fromItems([
          InvoiceItem(description: 'A', quantity: 1, unitPrice: 10),
          InvoiceItem(
              description: 'B', quantity: 1, unitPrice: 10, discount: 50),
        ]),
        throwsA(isA<ArgumentError>()
            .having((e) => e.name, 'name', 'items[1].discount')),
      );
      expect(
        () => InvoiceCalculator.fromItems([
          InvoiceItem(description: 'A', quantity: double.nan, unitPrice: 10),
        ]),
        throwsArgumentError,
      );
    });
  });

  group('InvoiceItem', () {
    test('Invoice item calculations', () {
      final item = InvoiceItem(
        description: 'Test Item',
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

    test('defaults to 18% and no discount', () {
      final item = InvoiceItem(description: 'Pen', quantity: 4, unitPrice: 25);
      expect(item.taxRate, 18);
      expect(item.discount, 0);
      expect(item.total, 118);
    });
  });

  group('value equality', () {
    test('InvoiceItem and InvoiceResult compare by value', () {
      const a = InvoiceItem(description: 'Pen', quantity: 2, unitPrice: 10);
      const b = InvoiceItem(description: 'Pen', quantity: 2, unitPrice: 10);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(
          a,
          isNot(const InvoiceItem(
              description: 'Pen', quantity: 3, unitPrice: 10)));
      expect(
          InvoiceCalculator.fromItems([a]), InvoiceCalculator.fromItems([b]));
      expect(a.toString(), contains('description: Pen'));
    });

    test('TdsResult compares by value', () {
      expect(TdsCalculator.calculate(amount: 100, rate: 10),
          const TdsResult(tds: 10, netAmount: 90));
    });
  });
}
