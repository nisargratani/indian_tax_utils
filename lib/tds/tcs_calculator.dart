import '../models/tds_result.dart';

class TcsCalculator {
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
