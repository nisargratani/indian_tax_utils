import 'package:indian_tax_utils/indian_tax_utils.dart';
import 'package:test/test.dart';

void main() {
  group('TdsCalculator', () {
    test('TDS calculation', () {
      final result = TdsCalculator.calculate(
        amount: 10000,
        rate: 10,
      );

      expect(result.tds, 1000);
      expect(result.netAmount, 9000);
    });

    test('zero rate deducts nothing', () {
      final result = TdsCalculator.calculate(amount: 5000, rate: 0);
      expect(result.tds, 0);
      expect(result.netAmount, 5000);
    });

    test('rejects rates outside 0..100 and non-finite amounts', () {
      expect(() => TdsCalculator.calculate(amount: 100, rate: -1),
          throwsArgumentError);
      expect(() => TdsCalculator.calculate(amount: 100, rate: 101),
          throwsArgumentError);
      expect(() => TdsCalculator.calculate(amount: double.nan, rate: 10),
          throwsArgumentError);
    });
  });

  group('TcsCalculator', () {
    test('TCS calculation', () {
      final result = TcsCalculator.calculate(
        amount: 10000,
        rate: 0.1,
      );

      expect(result.tds, 10);
      expect(result.netAmount, 10010);
    });

    test('rejects invalid rate', () {
      expect(() => TcsCalculator.calculate(amount: 100, rate: -0.1),
          throwsArgumentError);
    });
  });
}
