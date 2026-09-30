/// Format validators for Indian tax identifiers.
library;

/// Format validators for PAN, GSTIN and TAN.
///
/// These check an identifier's structure (and, optionally, a GSTIN's check
/// digit). They do not confirm that the identifier has been issued; use the
/// Income Tax or GST portal for that. Input is matched case-insensitively but
/// must not contain spaces.
abstract final class TaxValidators {
  // The 4th PAN character is the holder type: A (association of persons),
  // B (body of individuals), C (company), F (firm/LLP), G (government),
  // H (HUF), J (artificial juridical person), L (local authority),
  // P (individual) or T (trust).
  static const String _panPattern = '[A-Z]{3}[ABCFGHJLPT][A-Z][0-9]{4}[A-Z]';
  static final RegExp _pan = RegExp('^$_panPattern\$');
  static final RegExp _gstin =
      RegExp('^[0-9]{2}$_panPattern[1-9A-Z]Z[0-9A-Z]\$');
  static final RegExp _tan = RegExp(r'^[A-Z]{4}[0-9]{5}[A-Z]$');

  static const String _gstinCharset = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  /// Whether [pan] has the format of a PAN: five letters, four digits and a
  /// letter, where the fourth letter is a valid holder type (`P` for an
  /// individual, `C` for a company, and so on), e.g. `ABCPE1234F`.
  static bool isValidPan(String pan) => _pan.hasMatch(pan.toUpperCase());

  /// Whether [gstin] has the format of a regular taxpayer's 15-character
  /// GSTIN: a 2-digit state code, a PAN (checked as by [isValidPan]), an
  /// entity number, `Z`, and a check character, e.g. `27AAPFU0939F1ZV`.
  ///
  /// By default only the format is checked. Set [verifyChecksum] to `true` to
  /// also verify the final check character, which catches most typing
  /// mistakes:
  ///
  /// ```dart
  /// TaxValidators.isValidGstin('27AAPFU0939F1ZV', verifyChecksum: true); // true
  /// TaxValidators.isValidGstin('27AAPFU0939F1ZX', verifyChecksum: true); // false
  /// ```
  ///
  /// Special registrations that do not have `Z` as the 14th character (such
  /// as TDS/TCS deductors or UN bodies) are not accepted.
  static bool isValidGstin(String gstin, {bool verifyChecksum = false}) {
    final value = gstin.toUpperCase();
    if (!_gstin.hasMatch(value)) return false;
    return !verifyChecksum || value[14] == _gstinCheckChar(value);
  }

  /// Whether [tan] has the format of a TAN: four letters, five digits and a
  /// letter, e.g. `MUMA12345B`.
  static bool isValidTan(String tan) => _tan.hasMatch(tan.toUpperCase());

  // GSTN's mod-36 check character over the first 14 characters.
  static String _gstinCheckChar(String gstin) {
    var sum = 0;
    for (var i = 0; i < 14; i++) {
      final product = _gstinCharset.indexOf(gstin[i]) * (i.isOdd ? 2 : 1);
      sum += product ~/ 36 + product % 36;
    }
    return _gstinCharset[(36 - sum % 36) % 36];
  }
}
