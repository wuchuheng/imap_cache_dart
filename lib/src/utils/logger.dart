class Logger {
  static bool isShowLog = false;
  static info(String message) {
    if (!isShowLog)  return ;
    DateTime now = DateTime.now();
    print(
      '${now.year}/${now.month}/${now.day} ${now.hour}:${now.minute}:${now.second} $message',
    );
  }

  static error(String message) {
    if (!isShowLog)  return ;
    DateTime now = DateTime.now();
    print(
      'ERROR ${now.year}/${now.month}/${now.day} ${now.hour}:${now.minute}:${now.second} $message',
    );
  }
}
