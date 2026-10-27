import 'package:intl/intl.dart';

class DateFormatters {
  static final monthDayYear = DateFormat('MMM d, yyyy');
  static final monthDay = DateFormat('MMM d');
  static final longMonthDayYear = DateFormat('MMMM d, yyyy');
  static final timelineStamp = DateFormat('MMMM d').addPattern('', 'en_US');
  static final shortStamp = DateFormat('MMM d').addPattern('', 'en_US');

  static String tripRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${DateFormat('MMM d').format(start)} — ${DateFormat('d, yyyy').format(end)}';
    }
    if (start.year == end.year) {
      return '${DateFormat('MMM d').format(start)} — ${DateFormat('MMM d, yyyy').format(end)}';
    }
    return '${monthDayYear.format(start)} — ${monthDayYear.format(end)}';
  }

  static String memoryDate(DateTime date) => longMonthDayYear.format(date);

  static String feedDate(DateTime date) => monthDay.format(date);

  static String timelineHeader(DateTime date) =>
      DateFormat('MMMM d').format(date).toUpperCase();

  static String stamp(DateTime date) =>
      '${DateFormat('MMM d').format(date).toUpperCase()} · ${date.year}';

  static int dayCount(DateTime start, DateTime end) =>
      end.difference(start).inDays + 1;
}
