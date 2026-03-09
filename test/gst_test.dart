import 'package:test/test.dart';
import 'package:indian_tax_utils/indian_tax_utils.dart';

void main() {
  group('GstCalculator', () {
    test("GST split intra state", () {
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

    test("GST split inter state", () {
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
  });

  group('GstInclusiveCalculator', () {
    test("Extract GST from inclusive amount", () {
      final result = GstInclusiveCalculator.extractGST(
        amount: 118,
        rate: 18,
      );

      expect(result['base'], 100);
      expect(result['tax'], 18);
    });
  });

  group('GstSplit', () {
    test("Split total tax intra state", () {
      final result = GstSplit.split(
        totalTax: 180,
        intraState: true,
      );

      expect(result.cgst, 90);
      expect(result.sgst, 90);
      expect(result.igst, 0);
    });
  });
}
