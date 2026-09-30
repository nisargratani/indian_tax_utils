/// Indian currency formatting.
library;

import '../internal/rounding.dart';

/// Formats amounts in the Indian numbering system (lakhs and crores).
abstract final class CurrencyHelper {
  /// Formats [amount] with Indian digit grouping, e.g. `₹ 1,23,45,678.90`.
  ///
  /// The last three whole-number digits are grouped together and the rest in
  /// pairs. [amount] is rounded half away from zero to [decimals] places.
  /// Set [symbol] to `false` to omit the `"₹ "` prefix. A negative sign goes
  /// before the symbol (`-₹ 1,234.50`); an amount that rounds to zero is
  /// never shown as negative.
  ///
  /// ```dart
  /// CurrencyHelper.format(123456.78);                // ₹ 1,23,456.78
  /// CurrencyHelper.format(1500, symbol: false);      // 1,500.00
  /// CurrencyHelper.format(1234567.6, decimals: 0);   // ₹ 12,34,568
  /// ```
  ///
  /// Throws an [ArgumentError] if [amount] is not finite or its magnitude is
  /// 10^21 or more, and a [RangeError] if [decimals] is outside `0..20`.
  static String format(double amount, {bool symbol = true, int decimals = 2}) {
    RangeError.checkValueInInterval(decimals, 0, 20, 'decimals');
    if (!amount.isFinite) {
      throw ArgumentError.value(amount, 'amount', 'Must be a finite number');
    }

    final rounded = roundHalfAwayFromZero(amount, decimals);
    // toStringAsFixed switches to exponent notation from 1e21.
    if (amount.abs() >= 1e21 || rounded.abs() >= 1e21) {
      throw ArgumentError.value(amount, 'amount', 'Must be less than 1e21');
    }

    final sign = rounded < 0 ? '-' : '';
    final parts = rounded.abs().toStringAsFixed(decimals).split('.');
    final whole = parts[0];
    final fraction = parts.length > 1 ? '.${parts[1]}' : '';

    return '$sign${symbol ? '₹ ' : ''}${_group(whole)}$fraction';
  }

  // Inserts Indian-style separators: the last three digits, then pairs.
  static String _group(String digits) {
    if (digits.length <= 3) return digits;

    final head = digits.substring(0, digits.length - 3);
    final buffer = StringBuffer();
    final firstPair = head.length.isOdd ? 1 : 2;
    buffer.write(head.substring(0, firstPair));
    for (var i = firstPair; i < head.length; i += 2) {
      buffer
        ..write(',')
        ..write(head.substring(i, i + 2));
    }
    buffer
      ..write(',')
      ..write(digits.substring(digits.length - 3));
    return buffer.toString();
  }
}
