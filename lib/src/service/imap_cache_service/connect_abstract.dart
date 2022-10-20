import 'package:wuchuheng_hooks/wuchuheng_hooks.dart';
import 'package:wuchuheng_imap_cache/src/dto/connect_config/index.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

import 'index_abstarct.dart';

abstract class ConnectAbstract {
  Future<ImapCacheService> connectToServer(ConnectConfig config);
  Unsubscribe subscribeLog(void Function(LoggerItem loggerItem) callback);
  Future<void> disconnect();
}
