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
void checkDiscount(double discount, double amount, String name) {
  if (!discount.isFinite || discount < 0) {
    throw ArgumentError.value(
      discount,
      name,
      'Must be a finite, non-negative amount',
    );
  }
  if (discount > 0 && discount > amount) {
    throw ArgumentError.value(
      discount,
      name,
      'Must not exceed the amount it is applied to ($amount)',
    );
  }
}
