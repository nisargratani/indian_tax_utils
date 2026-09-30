import 'package:indian_tax_utils/indian_tax_utils.dart';
import 'package:test/test.dart';

void main() {
  group('GstCalculator', () {
    test('GST split intra state', () {
      final result = GstCalculator.calculate(
        amount: 1000,
        rate: 18,
        intraState: true,
      );

      expect(result.cgst, 90);
      expect(result.sgst, 90);
      expect(result.igst, 0);
      expect(result.totalTax, 180);
    });

    test('GST split inter state', () {
      final result = GstCalculator.calculate(
        amount: 1000,
        rate: 18,
        intraState: false,
      );

      expect(result.cgst, 0);
      expect(result.sgst, 0);
      expect(result.igst, 180);
      expect(result.totalTax, 180);
    });

    test('zero rate and zero amount give zero tax', () {
      expect(
        GstCalculator.calculate(amount: 1000, rate: 0, intraState: true)
            .totalTax,
        0,
      );
      expect(
        GstCalculator.calculate(amount: 0, rate: 18, intraState: false)
            .totalTax,
        0,
      );
    });

    test('negative amount (credit note) gives negative tax', () {
      final result =
          GstCalculator.calculate(amount: -1000, rate: 18, intraState: true);
      expect(result.cgst, -90);
      expect(result.totalTax, -180);
    });

    test('accepts GstRate.percentage', () {
      final result = GstCalculator.calculate(
        amount: 1000,
        rate: GstRate.forty.percentage,
        intraState: false,
      );
      expect(result.igst, 400);
    });

    test('rejects non-finite amount and invalid rate', () {
      expect(
        () => GstCalculator.calculate(
            amount: double.nan, rate: 18, intraState: true),
        throwsArgumentError,
      );
      expect(
        () => GstCalculator.calculate(
            amount: double.infinity, rate: 18, intraState: true),
        throwsArgumentError,
      );
      expect(
        () => GstCalculator.calculate(amount: 100, rate: -5, intraState: true),
        throwsArgumentError,
      );
    });
  });

  group('GstInclusiveCalculator', () {
    test('Extract GST from inclusive amount', () {
      final result = GstInclusiveCalculator.extractGST(
        amount: 118,
        rate: 18,
      );

      expect(result['base'], 100);
      expect(result['tax'], 18);
    });

    test('base + tax equals the inclusive amount', () {
      final result = GstInclusiveCalculator.extractGST(amount: 1000, rate: 18);
      expect(result['base']! + result['tax']!, closeTo(1000, 1e-9));
      expect(result['base'], closeTo(847.4576, 1e-4));
    });

    test('zero rate leaves everything in base', () {
      final result = GstInclusiveCalculator.extractGST(amount: 500, rate: 0);
      expect(result['base'], 500);
      expect(result['tax'], 0);
    });

    test('rejects a negative rate instead of returning Infinity', () {
      expect(
        () => GstInclusiveCalculator.extractGST(amount: 100, rate: -100),
        throwsArgumentError,
      );
    });
  });

  group('GstSplit', () {
    test('Split total tax intra state', () {
      final result = GstSplit.split(
        totalTax: 180,
        intraState: true,
      );

      expect(result.cgst, 90);
      expect(result.sgst, 90);
      expect(result.igst, 0);
    });

    test('Split total tax inter state', () {
      final result = GstSplit.split(totalTax: 180, intraState: false);
      expect(result.cgst, 0);
      expect(result.sgst, 0);
      expect(result.igst, 180);
      expect(result.totalTax, 180);
    });

    test('rejects non-finite tax', () {
      expect(
        () => GstSplit.split(totalTax: double.nan, intraState: true),
        throwsArgumentError,
      );
    });
  });

  group('GstRate', () {
    test('keeps existing values and indexes', () {
      expect(GstRate.values.take(5).map((r) => r.rate), [0, 5, 12, 18, 28]);
      expect(GstRate.twentyEight.index, 4);
    });

    test('has the 40% slab and a double percentage', () {
      expect(GstRate.forty.rate, 40);
      expect(GstRate.eighteen.percentage, 18.0);
    });
  });

  group('GstResult', () {
    test('has value equality', () {
      final a =
          GstCalculator.calculate(amount: 100, rate: 18, intraState: true);
      final b = GstSplit.split(totalTax: 18, intraState: true);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(GstSplit.split(totalTax: 18, intraState: false)));
    });
  });
}
