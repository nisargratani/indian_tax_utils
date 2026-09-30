/// Standard GST rate slabs.
library;

/// Standard GST rate slabs.
///
/// Since 22 September 2025 the main slabs are 5% and 18%, with a special 40%
/// rate for luxury and sin goods. [twelve] and [twentyEight] remain for
/// historical invoices and the goods that still carry those rates.
///
/// Calculators take the rate as a `double`, so pass [percentage]:
///
/// ```dart
/// GstCalculator.calculate(
///   amount: 1000,
///   rate: GstRate.eighteen.percentage,
///   intraState: true,
/// );
/// ```
enum GstRate {
  /// 0% (nil-rated / exempt supplies).
  zero(0),

  /// 5%.
  five(5),

  /// 12%. Largely merged into 5% from 22 September 2025.
  twelve(12),

  /// 18% (the standard rate).
  eighteen(18),

  /// 28%. Largely merged into 18% from 22 September 2025.
  twentyEight(28),

  /// 40% (special rate for luxury and sin goods from 22 September 2025).
  forty(40);

  /// The rate as a whole-number percentage, e.g. `18` for 18%.
  final int rate;

  /// Creates a [GstRate] with the given percentage.
  const GstRate(this.rate);

  /// The rate as a `double` percentage, ready to pass to the calculators.
  double get percentage => rate.toDouble();
}
