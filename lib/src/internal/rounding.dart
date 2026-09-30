/// Floating-point-safe rounding shared by the helpers. Not exported.
library;

const List<double> _powersOf10 = [
  1e0, 1e1, 1e2, 1e3, 1e4, 1e5, 1e6, 1e7, 1e8, 1e9, 1e10, //
  1e11, 1e12, 1e13, 1e14, 1e15, 1e16, 1e17, 1e18, 1e19, 1e20,
];

/// Returns `value * 10^decimals` rounded half away from zero to a whole
/// number (as a double). [decimals] must be in `0..20`.
///
/// Binary doubles cannot represent most decimal fractions exactly, so a value
/// such as `1.005` is stored as `1.00499999...`, and `1.005 * 100` evaluates
/// to `100.49999999999999`. A scaled value within a relative 1e-15 (a few
/// units in the last place) of an exact half is therefore treated as that
/// half, so decimal halves round the way people expect. From 1e14 upwards
/// that window would span a large part of the unit being rounded, so such
/// values are rounded as-is.
///
/// NaN and infinities are returned unchanged.
double roundedUnits(double value, int decimals) {
  if (!value.isFinite) return value;
  final scaled = value * _powersOf10[decimals];
  final magnitude = scaled.abs();
  if (magnitude >= 1e14) return scaled.roundToDouble();

  final floor = magnitude.floorToDouble();
  final distanceFromHalf = (magnitude - floor - 0.5).abs();
  final rounded = distanceFromHalf <= magnitude * 1e-15
      ? floor + 1
      : magnitude.roundToDouble();
  return scaled < 0 ? -rounded : rounded;
}

/// Rounds [value] to [decimals] places, half away from zero.
///
/// Never returns negative zero.
double roundHalfAwayFromZero(double value, int decimals) {
  if (!value.isFinite) return value;
  // Adding 0.0 turns -0.0 into 0.0.
  return roundedUnits(value, decimals) / _powersOf10[decimals] + 0.0;
}
