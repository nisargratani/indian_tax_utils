/// Utility library for GST rates.
library gst_rate;

/// Defines standard GST rates.
enum GstRate {
  /// 0% GST Rate
  zero(0),
  /// 5% GST Rate
  five(5),
  /// 12% GST Rate
  twelve(12),
  /// 18% GST Rate
  eighteen(18),
  /// 28% GST Rate
  twentyeight(28);

  /// The integer value of the GST rate.
  final int rate;

  /// Creates a [GstRate] with the specified integer rate.
  const GstRate(this.rate);
}
