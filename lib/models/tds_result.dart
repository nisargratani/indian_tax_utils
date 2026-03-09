class TdsResult {
  final double tds;
  final double netAmount;

  TdsResult({
    required this.tds,
    required this.netAmount,
  });

  @override
  String toString() {
    return 'TdsResult(tds: $tds, netAmount: $netAmount)';
  }
}
