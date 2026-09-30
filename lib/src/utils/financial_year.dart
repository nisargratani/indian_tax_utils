/// Indian financial year helpers.
library;

/// Helpers for the Indian financial year, which runs from 1 April to
/// 31 March.
abstract final class FinancialYear {
  /// Returns the financial year containing [date], formatted as `"YYYY-YY"`.
  ///
  /// ```dart
  /// FinancialYear.get(DateTime(2024, 3, 31)); // "2023-24"
  /// FinancialYear.get(DateTime(2024, 4, 1));  // "2024-25"
  /// ```
  ///
  /// Only the calendar year and month of [date] are used, so local and UTC
  /// dates are treated alike.
  static String get(DateTime date) {
    final startYear = date.month >= 4 ? date.year : date.year - 1;
    final end = ((startYear + 1) % 100).toString().padLeft(2, '0');
    return '$startYear-$end';
  }

  /// Whether [date] falls within the financial year [fy], which must use the
  /// same `"YYYY-YY"` format that [get] returns (e.g. `"2023-24"`).
  static bool isDateInFY(DateTime date, String fy) {
    return get(date) == fy;
  }

  /// Returns the current financial year, based on the device's local date.
  static String current() => get(DateTime.now());
}
