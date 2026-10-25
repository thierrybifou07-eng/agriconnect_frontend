import 'package:intl/intl.dart';

abstract final class Money {
  static String format(double amount) {
    final fractionDigits = amount == amount.truncateToDouble() ? 0 : 2;
    final formatter = NumberFormat.decimalPattern('fr_FR')
      ..minimumFractionDigits = fractionDigits
      ..maximumFractionDigits = fractionDigits;
    final formatted = formatter
        .format(amount)
        .replaceAll(RegExp(r'[\u00a0\u202f]'), ' ');
    return '$formatted FCFA';
  }
}
