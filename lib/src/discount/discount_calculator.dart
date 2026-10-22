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
  /// Throws an [ArgumentError] if [amount] is not finite, if [percent] is not
  /// between 0 and 100, or if the result is not finite (an [amount] so large
  /// that the calculation overflows).
  static double percentage({
    required double amount,
    required double percent,
  }) {
    checkFinite(amount, 'amount');
    checkRate(percent, 'percent', max: 100);
    // Adding 0.0 turns -0.0 (e.g. -100 at 0%) into 0.0.
    final discount = amount * percent / 100 + 0.0;
    checkResult(discount, amount, 'amount');
    return discount;
  }

  /// Returns [amount] after subtracting a flat [discount].
  ///
  /// ```dart
  /// DiscountCalculator.fixed(amount: 1000, discount: 100); // 900.0
  /// ```
  ///
  /// A [discount] that exceeds [amount] only by floating-point noise (as in
  /// `fixed(amount: 7 * 19.99, discount: 139.93)`, where `7 * 19.99` is
  /// `139.92999999999998`) is a full discount and returns `0.0`.
  ///
  /// Throws an [ArgumentError] if either value is not finite, or if
  /// [discount] is negative or greater than [amount].
  static double fixed({
    required double amount,
    required double discount,
  }) {
    checkFinite(amount, 'amount');
    checkDiscount(discount, amount, 'discount');
    if (discount > 0 && discount > amount) return 0.0;
    // Adding 0.0 turns -0.0 into 0.0.
    return amount - discount + 0.0;
  }
}
