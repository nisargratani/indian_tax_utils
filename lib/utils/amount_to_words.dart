class AmountToWords {
  static const List<String> _units = [
    "", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
    "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen",
    "Seventeen", "Eighteen", "Nineteen"
  ];

  static const List<String> _tens = [
    "", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"
  ];

  /// Converts a double amount to Words in Indian numbering system (Lakhs, Crores)
  static String convert(double amount) {
    if (amount == 0) return "Zero";
    if (amount < 0) return "Minus " + convert(amount.abs());

    int totalPaise = (amount * 100).round();
    int rupees = totalPaise ~/ 100;
    int paise = totalPaise % 100;

    String words = _convertToWords(rupees) + " Rupees";
    if (paise > 0) {
      words += " and " + _convertToWords(paise) + " Paise";
    }

    return words + " Only";
  }

  static String _convertToWords(int n) {
    if (n == 0) return "";

    if (n < 20) {
      return _units[n];
    }

    if (n < 100) {
      return _tens[n ~/ 10] + (n % 10 != 0 ? " " + _units[n % 10] : "");
    }

    if (n < 1000) {
      return _units[n ~/ 100] + " Hundred" + (n % 100 != 0 ? " and " + _convertToWords(n % 100) : "");
    }

    if (n < 100000) {
      return _convertToWords(n ~/ 1000) + " Thousand" + (n % 1000 != 0 ? " " + _convertToWords(n % 1000) : "");
    }

    if (n < 10000000) {
      return _convertToWords(n ~/ 100000) + " Lakh" + (n % 100000 != 0 ? " " + _convertToWords(n % 100000) : "");
    }

    return _convertToWords(n ~/ 10000000) + " Crore" + (n % 10000000 != 0 ? " " + _convertToWords(n % 10000000) : "");
  }
}
