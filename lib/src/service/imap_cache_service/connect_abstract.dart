import 'package:wuchuheng_imap_cache/src/dto/connect_config/index.dart';

import 'index_abstarct.dart';

abstract class ConnectAbstract {
  Future<ImapCacheServiceAbstract> connectToServer(ConnectConfig config);
}
