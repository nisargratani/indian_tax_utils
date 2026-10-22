/// Argument validation shared by the calculators. Not exported.
library;

/// Throws an [ArgumentError] if [value] is NaN or infinite.
void checkFinite(double value, String name) {
  if (!value.isFinite) {
    throw ArgumentError.value(value, name, 'Must be a finite number');
  }
}

/// Throws an [ArgumentError] unless [value] is a finite, non-negative
/// percentage, no greater than [max] when one is given.
void checkRate(double value, String name, {int? max}) {
  if (!value.isFinite || value < 0 || (max != null && value > max)) {
    throw ArgumentError.value(
      value,
      name,
      max != null
          ? 'Must be a percentage between 0 and $max'
          : 'Must be a finite, non-negative percentage',
    );
  }
}

/// Throws an [ArgumentError] unless [discount] is finite, non-negative and
/// no greater than the [amount] it is applied to.
///
/// An [amount] computed as `quantity * unitPrice` can land a unit in the last
/// place below its decimal value (`7 * 19.99` is `139.92999999999998`), so a
/// discount that exceeds [amount] by no more than a relative 1e-14 (a few
/// dozen units in the last place) is treated as equal to it.
void checkDiscount(double discount, double amount, String name) {
  if (!discount.isFinite || discount < 0) {
    throw ArgumentError.value(
      discount,
      name,
      'Must be a finite, non-negative amount',
    );
  }
  if (discount > 0 && discount - amount > amount.abs() * 1e-14) {
    throw ArgumentError.value(
      discount,
      name,
      'Must not exceed the amount it is applied to ($amount)',
    );
  }
}

/// Throws an [ArgumentError] for the argument [name], whose value is
/// [value], if a [result] computed from it is NaN or infinite (because the
/// calculation overflowed).
void checkResult(double result, Object? value, String name) {
  if (!result.isFinite) {
    throw ArgumentError.value(value, name, 'Result is not finite');
  }
}
