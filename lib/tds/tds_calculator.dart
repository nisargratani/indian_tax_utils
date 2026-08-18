/// Utility library for TDS calculation.
library tds_calculator;

import '../models/tds_result.dart';

/// A utility class for calculating Tax Deducted at Source (TDS).
class TdsCalculator {
  /// Default constructor.
  TdsCalculator();

  /// Calculates Tax Deducted at Source (TDS)
  static TdsResult calculate({
    required double amount,
    required double rate,
  }) {
    final tds = amount * rate / 100;

    return TdsResult(
      tds: tds,
      netAmount: amount - tds,
    );
  }
}
