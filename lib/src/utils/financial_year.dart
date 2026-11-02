/// Indian financial year helpers.
library;

/// Helpers for the Indian financial year, which runs from 1 April to
/// 31 March.
abstract final class FinancialYear {
  // Indian Standard Time is UTC+05:30 all year (India has no daylight
  // saving time).
  static const Duration _istOffset = Duration(hours: 5, minutes: 30);

  /// Returns the financial year containing [date], formatted as `"YYYY-YY"`.
  ///
  /// ```dart
  /// FinancialYear.get(DateTime(2024, 3, 31)); // "2023-24"
  /// FinancialYear.get(DateTime(2024, 4, 1));  // "2024-25"
  /// ```
  ///
  /// The financial year follows the date in India:
  ///
  /// - A UTC [date] (`isUtc` is `true`) is an instant, such as a timestamp
  ///   parsed from an API with `Z` or an offset. It is converted to Indian
  ///   Standard Time (UTC+05:30) first, so 2026-03-31T19:00Z, which is
  ///   00:30 IST on 1 April 2026, is in `"2026-27"`.
  /// - A local [date] is used as a calendar date without conversion, so a
  ///   date a user picked or typed never shifts, whatever the device's time
  ///   zone.
  static String get(DateTime date) {
    final indian = date.isUtc ? date.add(_istOffset) : date;
    final startYear = indian.month >= 4 ? indian.year : indian.year - 1;
    final end = ((startYear + 1) % 100).toString().padLeft(2, '0');
    return '$startYear-$end';
  }

  /// Whether [date] falls within the financial year [fy], which must use the
  /// same `"YYYY-YY"` format that [get] returns (e.g. `"2023-24"`). UTC and
  /// local dates are handled as by [get].
  static bool isDateInFY(DateTime date, String fy) {
    return get(date) == fy;
  }

  /// Returns the current financial year, based on today's date in India
  /// (IST), whatever the device's or server's time zone.
  static String current() => get(DateTime.now().toUtc());
}
