import 'package:test/test.dart';
import 'package:indian_tax_utils/indian_tax_utils.dart';

void main() {
  group('TdsCalculator', () {
    test("TDS calculation", () {
      final result = TdsCalculator.calculate(
        amount: 10000,
        rate: 10,
      );

      expect(result.tds, 1000);
      expect(result.netAmount, 9000);
    });
  });

  group('TcsCalculator', () {
    test("TCS calculation", () {
      final result = TcsCalculator.calculate(
        amount: 10000,
        rate: 0.1,
      );

      expect(result.tds, 10);
      expect(result.netAmount, 10010);
    });
  });
}
