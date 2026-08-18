/// Utility library for TCS calculation.
library tcs_calculator;

import '../models/tds_result.dart';

/// A utility class for calculating Tax Collected at Source (TCS).
class TcsCalculator {
  /// Default constructor.
  TcsCalculator();

  /// Calculates Tax Collected at Source (TCS)
  /// TCS is added on top of the invoice amount including GST usually.
  static TdsResult calculate({
    required double amount,
    required double rate,
  }) {
    final tcs = amount * rate / 100;

    return TdsResult(
      tds: tcs,
      netAmount: amount + tcs,
    );
  }
}
