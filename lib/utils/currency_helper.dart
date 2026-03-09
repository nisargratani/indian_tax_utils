class CurrencyHelper {
  /// Formats a double value into Indian Currency format (₹ #,##,###.##)
  static String format(double amount, {bool symbol = true, int decimals = 2}) {
    String sign = amount < 0 ? "-" : "";
    double absAmount = amount.abs();
    
    String strAmount = absAmount.toStringAsFixed(decimals);
    List<String> parts = strAmount.split('.');
    String whole = parts[0];
    String fraction = parts.length > 1 ? "." + parts[1] : "";

    if (whole.length <= 3) {
      return (symbol ? "₹ " : "") + sign + whole + fraction;
    }

    String lastThree = whole.substring(whole.length - 3);
    String remaining = whole.substring(0, whole.length - 3);

    String formattedRemaining = "";
    int count = 0;
    for (int i = remaining.length - 1; i >= 0; i--) {
      formattedRemaining = remaining[i] + formattedRemaining;
      count++;
      if (count == 2 && i != 0) {
        formattedRemaining = "," + formattedRemaining;
        count = 0;
      }
    }

    return (symbol ? "₹ " : "") + sign + formattedRemaining + "," + lastThree + fraction;
  }
}
