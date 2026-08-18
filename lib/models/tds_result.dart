/// Utility library for TDS result model.
library tds_result;

/// Model class representing the result of a TDS calculation.
class TdsResult {
  /// The TDS amount.
  final double tds;
  /// The net amount after TDS.
  final double netAmount;

  /// Creates a [TdsResult] instance.
  TdsResult({
    required this.tds,
    required this.netAmount,
  });

  @override
  String toString() {
    return 'TdsResult(tds: $tds, netAmount: $netAmount)';
  }
}
