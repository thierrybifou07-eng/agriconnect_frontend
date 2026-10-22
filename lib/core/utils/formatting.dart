import 'package:intl/intl.dart';

/// Money helpers for FCFA prices.
abstract final class Money {
  static const String code = 'FCFA';

  /// Formats [amount] with thousands separators and the currency suffix.
  static String format(int amount, {String locale = 'fr'}) =>
      '${NumberFormat.decimalPattern(locale).format(amount)} $code';
}

/// Date formatting helpers.
abstract final class AppFormats {
  static String date(DateTime date, {String locale = 'fr'}) =>
      DateFormat.yMMMd(locale).format(date);

  /// Compact timestamp for chat tiles: time today, day this year, else date.
  static String chatTimestamp(DateTime date, {String locale = 'fr'}) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    if (isToday) return DateFormat.Hm(locale).format(date);
    if (date.year == now.year) return DateFormat.MMMd(locale).format(date);
    return DateFormat.yMMMd(locale).format(date);
  }
}
