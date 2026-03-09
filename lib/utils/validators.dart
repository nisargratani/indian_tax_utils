class TaxValidators {
  /// Validates Indian PAN card number
  static bool isValidPan(String pan) {
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    return panRegex.hasMatch(pan.toUpperCase());
  }

  /// Validates Indian GSTIN (GST Identification Number)
  static bool isValidGstin(String gstin) {
    final gstinRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
    return gstinRegex.hasMatch(gstin.toUpperCase());
  }

  /// Validates Indian TAN (Tax Deduction Account Number)
  static bool isValidTan(String tan) {
    final tanRegex = RegExp(r'^[A-Z]{4}[0-9]{5}[A-Z]{1}$');
    return tanRegex.hasMatch(tan.toUpperCase());
  }
}
