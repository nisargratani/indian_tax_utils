/// GST extraction from a tax-inclusive amount.
library;

import '../internal/checks.dart';

/// Extracts GST from a tax-inclusive amount, such as an MRP or a price quoted
/// "inclusive of all taxes".
abstract final class GstInclusiveCalculator {
  /// Splits a GST-inclusive [amount] into its base value and the GST it
  /// contains at [rate] percent.
  ///
  /// Returns a map with two keys: `'base'` (the taxable value) and `'tax'`
  /// (the GST portion). `base + tax` equals [amount].
  ///
  /// ```dart
  /// final r = GstInclusiveCalculator.extractGST(amount: 118, rate: 18);
  /// // r['base'] == 100, r['tax'] == 18
  /// ```
  ///
  /// To split the extracted tax into CGST/SGST or IGST, pass `r['tax']!` to
  /// `GstSplit.split`. Results are not rounded.
  ///
  /// Throws an [ArgumentError] if [amount] is not finite or [rate] is negative
  /// or not finite.
  static Map<String, double> extractGST({
    required double amount,
    required double rate,
  }) {
    checkFinite(amount, 'amount');
    checkRate(rate, 'rate');

    final base = amount / (1 + rate / 100);
    final tax = amount - base;

    return {
      'base': base,
      'tax': tax,
    };
  }
}
