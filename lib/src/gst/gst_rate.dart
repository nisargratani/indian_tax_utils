/// Standard GST rate slabs.
library;

/// Standard GST rate slabs.
///
/// Since 22 September 2025 the main slabs are 5% and 18%, with a special 40%
/// rate for luxury and sin goods. Since 1 February 2026 no goods carry 28%
/// (tobacco and pan masala moved to 40%). [twelve] and [twentyEight] are
/// kept for historical invoices. [three] is the special rate for gold,
/// silver and jewellery.
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
///
/// Special rates that are not whole numbers, such as 0.25% (rough precious
/// stones) and 1.5% (cut and polished diamonds), have no value here because
/// [rate] is an `int`. Pass them to the calculators as doubles, for example
/// `rate: 1.5`.
enum GstRate {
  /// 0% (nil-rated / exempt supplies).
  zero(0),

  /// 5%.
  five(5),

  /// 12%. Largely moved to 5% (some goods to 18%) from 22 September 2025;
  /// kept for historical invoices.
  twelve(12),

  /// 18% (the standard rate).
  eighteen(18),

  /// 28%. No goods carry this rate since 1 February 2026; kept for
  /// historical invoices.
  twentyEight(28),

  /// 40% (special rate for luxury and sin goods from 22 September 2025).
  forty(40),

  /// 3% (special rate for gold, silver and jewellery).
  three(3);

  /// The rate as a whole-number percentage, e.g. `18` for 18%.
  final int rate;

  /// Creates a [GstRate] with the given percentage.
  const GstRate(this.rate);

  /// The rate as a `double` percentage, ready to pass to the calculators.
  double get percentage => rate.toDouble();
}
