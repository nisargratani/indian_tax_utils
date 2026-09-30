/// Discount helpers.
library;

import '../internal/checks.dart';

/// Discount helpers.
///
/// Note that the two methods return different things: [percentage] returns
/// the discount **amount**, while [fixed] returns the amount **after** the
/// discount.
abstract final class DiscountCalculator {
  /// Returns the discount amount for [percent] percent of [amount].
  ///
  /// ```dart
  /// DiscountCalculator.percentage(amount: 1000, percent: 10); // 100.0
  /// ```
  ///
  /// Throws an [ArgumentError] if [amount] is not finite or [percent] is not
  /// between 0 and 100.
  static double percentage({
    required double amount,
    required double percent,
  }) {
    checkFinite(amount, 'amount');
    checkRate(percent, 'percent', max: 100);
    return amount * percent / 100;
  }

  /// Returns [amount] after subtracting a flat [discount].
  ///
  /// ```dart
  /// DiscountCalculator.fixed(amount: 1000, discount: 100); // 900.0
  /// ```
  ///
  /// Throws an [ArgumentError] if either value is not finite, or if
  /// [discount] is negative or greater than [amount].
  static double fixed({
    required double amount,
    required double discount,
  }) {
    checkFinite(amount, 'amount');
    checkDiscount(discount, amount, 'discount');
    return amount - discount;
  }
}
