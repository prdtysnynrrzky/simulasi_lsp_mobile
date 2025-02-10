import 'package:intl/intl.dart';

class DateFormatHelper {
  static String format(DateTime date) {
    return DateFormat('dd MMMM yyyy, HH:mm', 'id').format(date);
  }
}
