import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _rsFormat = NumberFormat('#,##0', 'en_US');

  static String rupees(num value) => 'Rs ${_rsFormat.format(value)}';
  static String number(num value) => _rsFormat.format(value);

  static String compactRupees(num value) {
    if (value >= 1000000) {
      return 'Rs ${(value / 1000000).toStringAsFixed(2)}M';
    }
    if (value >= 1000) {
      return 'Rs ${(value / 1000).toStringAsFixed(0)}K';
    }
    return rupees(value);
  }

  static String shortDate(DateTime d) =>
      DateFormat('d MMM yyyy').format(d);

  static String dayLabel(DateTime d) =>
      DateFormat('EEE d MMM').format(d);
}
