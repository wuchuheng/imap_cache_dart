import 'package:wuchuheng_imap_cache/src/dto/connect_config/index.dart';
import 'package:wuchuheng_imap_cache/src/subscription/subscription_abstract.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

import 'index_abstarct.dart';

abstract class ConnectAbstract {
  Future<ImapCacheServiceAbstract> connectToServer(ConnectConfig config);
  UnsubscribeAbstract subscribeLog(void Function(LoggerItem loggerItem) calbblback);
}
