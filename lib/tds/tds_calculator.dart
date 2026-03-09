import '../models/tds_result.dart';

class TdsCalculator {
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
