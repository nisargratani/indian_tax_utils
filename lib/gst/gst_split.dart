import '../models/gst_result.dart';

class GstSplit {
  static GstResult split({
    required double totalTax,
    required bool intraState,
  }) {
    if (intraState) {
      return GstResult(
        cgst: totalTax / 2,
        sgst: totalTax / 2,
        igst: 0,
        totalTax: totalTax,
      );
    } else {
      return GstResult(
        cgst: 0,
        sgst: 0,
        igst: totalTax,
        totalTax: totalTax,
      );
    }
  }
}
