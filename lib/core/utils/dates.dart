import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

abstract final class Dates {
  static Future<void> initialize() async {
    await initializeDateFormatting('fr');
    await initializeDateFormatting('en');
    Intl.defaultLocale ??= 'fr';
  }

  static String short(DateTime date) =>
      DateFormat.yMMMd().format(date.toLocal());

  static String long(DateTime date) =>
      DateFormat.yMMMMEEEEd().format(date.toLocal());

  static String relative(DateTime date, {DateTime? now}) {
    final difference = date.toLocal().difference(now ?? DateTime.now());
    final absolute = difference.abs();
    final value = switch (absolute) {
      _ when absolute.inDays >= 1 => '${absolute.inDays} j',
      _ when absolute.inHours >= 1 => '${absolute.inHours} h',
      _ when absolute.inMinutes >= 1 => '${absolute.inMinutes} min',
      _ => 'moins d’une minute',
    };
    if (difference.inSeconds > 0) return 'dans $value';
    if (difference.inSeconds < 0) return 'il y a $value';
    return 'maintenant';
  }

  static String countdown(DateTime date, {DateTime? now}) {
    final remaining = date.toLocal().difference(now ?? DateTime.now());
    if (remaining.isNegative) return '00:00';
    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return remaining.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }
}
