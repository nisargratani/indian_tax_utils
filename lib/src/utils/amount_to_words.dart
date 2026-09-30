/// Amount-to-words conversion.
library;

import '../internal/rounding.dart';

/// Converts amounts to Indian English words using lakhs and crores, as
/// printed on invoices and cheques.
abstract final class AmountToWords {
  // 2^53 - 1: the largest paise count that is exact on every platform,
  // including the web, where integers are JavaScript doubles.
  static const int _maxPaise = 9007199254740991;

  static const List<String> _units = [
    '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', //
    'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen',
    'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen',
  ];

  static const List<String> _tens = [
    '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', //
    'Eighty', 'Ninety',
  ];

  /// Converts [amount] (in rupees) to words.
  ///
  /// The amount is rounded to the nearest paisa (half away from zero).
  ///
  /// ```dart
  /// AmountToWords.convert(123456.78);
  /// // One Lakh Twenty Three Thousand Four Hundred and Fifty Six Rupees
  /// // and Seventy Eight Paise Only
  /// AmountToWords.convert(1);    // One Rupee Only
  /// AmountToWords.convert(0.5);  // Fifty Paise Only
  /// AmountToWords.convert(-10);  // Minus Ten Rupees Only
  /// AmountToWords.convert(0);    // Zero Rupees Only
  /// ```
  ///
  /// Throws an [ArgumentError] if [amount] is not finite or its magnitude
  /// exceeds about 90 lakh crore (2^53 − 1 paise), beyond which a double
  /// can no longer represent every paisa exactly.
  static String convert(double amount) {
    if (!amount.isFinite) {
      throw ArgumentError.value(amount, 'amount', 'Must be a finite number');
    }

    final units = roundedUnits(amount.abs(), 2);
    if (units > _maxPaise) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Too large to convert exactly (maximum is ${_maxPaise ~/ 100} rupees)',
      );
    }

    final totalPaise = units.toInt();
    if (totalPaise == 0) return 'Zero Rupees Only';

    final rupees = totalPaise ~/ 100;
    final paise = totalPaise % 100;

    final parts = <String>[
      if (amount < 0) 'Minus',
      if (rupees > 0)
        '${_convertToWords(rupees)} ${rupees == 1 ? 'Rupee' : 'Rupees'}',
      if (rupees > 0 && paise > 0) 'and',
      if (paise > 0) '${_convertToWords(paise)} Paise',
      'Only',
    ];
    return parts.join(' ');
  }

  // Converts a positive integer to words. Numbers of a crore or more recurse
  // on the crore count, e.g. 10^12 is "One Lakh Crore".
  static String _convertToWords(int n) {
    if (n < 20) return _units[n];

    if (n < 100) {
      return _tens[n ~/ 10] + (n % 10 != 0 ? ' ${_units[n % 10]}' : '');
    }

    if (n < 1000) {
      return '${_units[n ~/ 100]} Hundred'
          '${n % 100 != 0 ? ' and ${_convertToWords(n % 100)}' : ''}';
    }

    if (n < 100000) return _scale(n, 1000, 'Thousand');
    if (n < 10000000) return _scale(n, 100000, 'Lakh');
    return _scale(n, 10000000, 'Crore');
  }

  static String _scale(int n, int unit, String name) {
    final rest = n % unit;
    return '${_convertToWords(n ~/ unit)} $name'
        '${rest != 0 ? ' ${_convertToWords(rest)}' : ''}';
  }
}
