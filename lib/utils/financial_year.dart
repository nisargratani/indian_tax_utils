class FinancialYear {
  /// Gets the financial year string for a given date (e.g., "2023-24")
  static String get(DateTime date) {
    int startYear;
    int endYear;

    if (date.month >= 4) {
      startYear = date.year;
      endYear = date.year + 1;
    } else {
      startYear = date.year - 1;
      endYear = date.year;
    }

    String start = startYear.toString();
    String end = endYear.toString().substring(2);

    return "$start-$end";
  }

  /// Checks if a date falls within a specific financial year (e.g., "2023-24")
  static bool isDateInFY(DateTime date, String fy) {
    return get(date) == fy;
  }

  /// Returns current financial year
  static String current() => get(DateTime.now());
}
