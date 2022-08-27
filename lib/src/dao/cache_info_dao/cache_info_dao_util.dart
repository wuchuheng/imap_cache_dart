import 'package:wuchuheng_imap_cache/src/model/cache_info_model/index.dart';
import 'package:sqlite3/common.dart';

import '../../utils/timer_util.dart';

class CacheInfoDaoUtil {
  static CacheInfoModel rowConvertCacheInfoModel(Row row) {
    final updatedAt = row['updated_at'];
    final deletedAt = row['deleted_at'];
    return CacheInfoModel(
      symbol: row['symbol'],
      uid: row['uid'],
      value: row['value'],
      key: row['key'],
      hash: row['hash'],
      updatedAt: TimerUtil.convertTimeStr(updatedAt),
      deletedAt: deletedAt != null ? TimerUtil.convertTimeStr(deletedAt) : null,
    );
  }
}
