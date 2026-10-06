import 'package:intl/intl.dart';

class AppDateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  static String formatDateString(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return formatDate(date);
    } catch (e) {
      return dateString;
    }
  }
}
