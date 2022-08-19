import 'package:intl/intl.dart';

class TimerUtil {
  static int timeStringConvertMilliseconds(String time) {
    return DateFormat("yyyy-MM-dd HH:mm:ss").parse(time).millisecondsSinceEpoch;
  }

  static DateTime convertTimeStr(String timeString) {
    return DateFormat("yyyy-MM-dd HH:mm:ss").parse(timeString);
  }
}
