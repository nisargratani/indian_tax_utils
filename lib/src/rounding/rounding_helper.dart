/// Rounding helpers for money values.
library;

import '../internal/rounding.dart';

/// Rounding helpers for money values.
///
/// All methods round half away from zero (`2.5` → `3`, `-2.5` → `-3`), the
/// convention used on Indian invoices, and correct for binary floating-point
/// noise so that decimal halves such as `1.005` round up as written. They
/// never return negative zero. NaN and infinities are returned unchanged.
abstract final class RoundingHelper {
  /// Rounds [value] to the nearest whole rupee.
  ///
  /// ```dart
  /// RoundingHelper.roundToNearest(100.49); // 100.0
  /// RoundingHelper.roundToNearest(100.50); // 101.0
  /// ```
  static double roundToNearest(double value) => roundHalfAwayFromZero(value, 0);

  /// Rounds [value] to [decimals] decimal places. The default of 2 rounds to
  /// the nearest paisa.
  ///
  /// ```dart
  /// RoundingHelper.roundTo(8.9991); // 9.0
  /// RoundingHelper.roundTo(1.005);  // 1.01
  /// ```
  ///
  /// Throws a [RangeError] if [decimals] is outside `0..15`.
  static double roundTo(double value, {int decimals = 2}) {
    RangeError.checkValueInInterval(decimals, 0, 15, 'decimals');
    return roundHalfAwayFromZero(value, decimals);
  }
}
