/// TDS/TCS calculation result.
library;

/// The result of a TDS or TCS calculation.
class TdsResult {
  /// The tax amount: TDS deducted (from `TdsCalculator`) or TCS collected
  /// (from `TcsCalculator`).
  final double tds;

  /// The amount after tax: `amount - tds` for TDS, `amount + tcs` for TCS.
  final double netAmount;

  /// Creates a [TdsResult].
  const TdsResult({
    required this.tds,
    required this.netAmount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TdsResult && other.tds == tds && other.netAmount == netAmount;

  @override
  int get hashCode => Object.hash(tds, netAmount);

  @override
  String toString() {
    return 'TdsResult(tds: $tds, netAmount: $netAmount)';
  }
}
