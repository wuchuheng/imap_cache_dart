import 'package:sqlite3/common.dart';

import '../../model/online_cache_info_model/index.dart';
import '../../utils/timer_util.dart';

class OnlineCacheInfoDaoUtil {
  static OnlineCacheInfoModel rowConvertCacheInfoModel(Row row) {
    final updatedAt = row['updated_at'];
    final deletedAt = row['deleted_at'];
    return OnlineCacheInfoModel(
      symbol: row['symbol'],
      uid: row['uid'],
      key: row['key'],
      hash: row['hash'],
      updatedAt: TimerUtil.convertTimeStr(updatedAt),
      deletedAt: deletedAt != null ? TimerUtil.convertTimeStr(deletedAt) : null,
    );
  }
}
