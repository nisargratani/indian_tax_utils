import 'package:indian_tax_utils/indian_tax_utils.dart';
import 'package:test/test.dart';

void main() {
  group('DiscountCalculator', () {
    test('percentage returns the discount amount', () {
      expect(DiscountCalculator.percentage(amount: 1000, percent: 10), 100);
      expect(DiscountCalculator.percentage(amount: 1000, percent: 0), 0);
      expect(DiscountCalculator.percentage(amount: 1000, percent: 100), 1000);
    });

    test('fixed returns the amount after discount', () {
      expect(DiscountCalculator.fixed(amount: 1000, discount: 100), 900);
      expect(DiscountCalculator.fixed(amount: 1000, discount: 1000), 0);
    });

    test('rejects impossible discounts', () {
      expect(() => DiscountCalculator.percentage(amount: 100, percent: 150),
          throwsArgumentError);
      expect(() => DiscountCalculator.percentage(amount: 100, percent: -5),
          throwsArgumentError);
      expect(() => DiscountCalculator.fixed(amount: 100, discount: 150),
          throwsArgumentError);
      expect(() => DiscountCalculator.fixed(amount: 100, discount: -5),
          throwsArgumentError);
    });
  });

  group('RoundingHelper.roundToNearest', () {
    test('rounds half away from zero', () {
      expect(RoundingHelper.roundToNearest(100.49), 100);
      expect(RoundingHelper.roundToNearest(100.50), 101);
      expect(RoundingHelper.roundToNearest(-100.5), -101);
    });

    test('never returns negative zero', () {
      final r = RoundingHelper.roundToNearest(-0.4);
      expect(r, 0);
      expect(r.isNegative, isFalse);
    });

    test('ignores floating-point noise just below .5', () {
      // 1.005 * 100 evaluates to 100.49999999999999.
      expect(RoundingHelper.roundToNearest(1.005 * 100), 101);
    });

    test('passes NaN and infinity through', () {
      expect(RoundingHelper.roundToNearest(double.nan).isNaN, isTrue);
      expect(RoundingHelper.roundToNearest(double.infinity), double.infinity);
    });
  });

  group('RoundingHelper.roundTo', () {
    test('rounds to paise by default', () {
      expect(RoundingHelper.roundTo(8.9991), 9.0);
      expect(RoundingHelper.roundTo(17.9982), 18.0);
      expect(RoundingHelper.roundTo(10.125), 10.13);
    });

    test('rounds decimal halves up despite binary representation', () {
      expect(RoundingHelper.roundTo(1.005), 1.01);
      expect(RoundingHelper.roundTo(2.675), 2.68);
      expect(RoundingHelper.roundTo(-1.005), -1.01);
    });

    test('supports other precisions', () {
      expect(RoundingHelper.roundTo(1234.5678, decimals: 0), 1235);
      expect(RoundingHelper.roundTo(1234.5678, decimals: 3), 1234.568);
    });

    test('rejects out-of-range decimals', () {
      expect(() => RoundingHelper.roundTo(1, decimals: -1), throwsRangeError);
      expect(() => RoundingHelper.roundTo(1, decimals: 16), throwsRangeError);
    });

    test('large values are rounded without losing digits', () {
      expect(RoundingHelper.roundTo(123456789012.345), 123456789012.35);
      expect(RoundingHelper.roundToNearest(1e16 + 2), 1e16 + 2);
    });
  });
}
