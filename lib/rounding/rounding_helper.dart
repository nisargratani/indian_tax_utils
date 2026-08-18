/// Utility library for rounding helper.
library rounding_helper;

/// A utility class for rounding numbers.
class RoundingHelper {
  /// Default constructor.
  RoundingHelper();

  /// Rounds a double value to the nearest integer.
  static double roundToNearest(double value) {
    return value.roundToDouble();
  }
}
