import '../models/gst_result.dart';

class GstCalculator {
  static GstResult calculate({
    required double amount,
    required double rate,
    required bool intraState,
  }) {
    final tax = amount * rate / 100;

    if (intraState) {
      return GstResult(
        cgst: tax / 2,
        sgst: tax / 2,
        igst: 0,
        totalTax: tax,
      );
    } else {
      return GstResult(
        cgst: 0,
        sgst: 0,
        igst: tax,
        totalTax: tax,
      );
    }
  }
}
