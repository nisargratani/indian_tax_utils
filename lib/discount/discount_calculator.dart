/// Utility library for discount calculation.
library discount_calculator;

/// A utility class for calculating discounts.
class DiscountCalculator {
  /// Default constructor.
  DiscountCalculator();

  /// Calculates the discount amount based on a percentage.
  static double percentage({
    required double amount,
    required double percent,
  }) {
    return amount * percent / 100;
  }

  /// Calculates the final amount after applying a fixed discount.
  static double fixed({
    required double amount,
    required double discount,
  }) {
    return amount - discount;
  }
}
