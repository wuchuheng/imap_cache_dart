import 'package:imap_cache/src/dao/cache_info_dao/cache_info_dao_util.dart';
import 'package:imap_cache/src/dao/cache_info_dao/index_abstract.dart';
import 'package:imap_cache/src/model/cache_info_model/index.dart';
import 'package:sqlite3/sqlite3.dart';

class CacheInfoDao implements CacheInfoDaoAbstract {
  final Database _db;

  CacheInfoDao({required Database db}) : _db = db;

  @override
  CacheInfoModel? findByKey({required String key}) {
    String tableName = CacheInfoModel.tableName;
    final ResultSet result = _db.select("select * from $tableName where `key` = ? Limit 1", [key]);
    if (result.isNotEmpty) {
      final Row row = result[0];
      return CacheInfoDaoUtil.rowConvertCacheInfoModel(row);
    }

    return null;
  }

  @override
  void save(CacheInfoModel cacheInfo) {
    final hasCacheInfo = findByKey(key: cacheInfo.key);
    final tableName = CacheInfoModel.tableName;
    if (hasCacheInfo != null) {
      _db.execute('''
      UPDATE $tableName SET 
        `value` = ?,
        `hash` = ?,
        `symbol` = ?,
        `updated_at` = ?,
        `deleted_at` = ?,
        `uid` = ?
        WHERE key ='${cacheInfo.key}'
      ''', [
        cacheInfo.value,
        cacheInfo.hash,
        cacheInfo.symbol,
        cacheInfo.updatedAt.toString(),
        cacheInfo.deletedAt?.toString(),
        cacheInfo.uid,
      ]);
    } else {
      _db.execute('''
      INSERT INTO $tableName (
        `uid`, `key`, `value`, `hash`, `symbol`, `updated_at`, `deleted_at`
      ) VALUES (? , ?, ?, ?, ?, ?,  ?) 
    ''', [
        cacheInfo.uid,
        cacheInfo.key,
        cacheInfo.value,
        cacheInfo.hash,
        cacheInfo.symbol,
        cacheInfo.updatedAt.toString(),
        cacheInfo.deletedAt?.toString(),
      ]);
    }
  }

  @override
  void destroyByKey({required String key}) {
    CacheInfoModel? cacheInfo = findByKey(key: key);
    if (cacheInfo != null) {
      cacheInfo.deletedAt = DateTime.now();
      save(cacheInfo);
    }
  }

  List<CacheInfoModel> fetchNotInclude(List<int> ignoreUids) {
    final tableName = CacheInfoModel.tableName;
    final fetchResult = _db.select('''SELECT * FROM `$tableName` WHERE `uid` NOT IN(?);''', [ignoreUids]);
    List<CacheInfoModel> result = [];
    for (Row row in fetchResult) {
      result.add(CacheInfoDaoUtil.rowConvertCacheInfoModel(row));
    }
    return result;
  }

  int fetchLastUid() {
    final tableName = CacheInfoModel.tableName;
    final fetchResult = _db.select('''SELECT `uid` FROM `$tableName` ORDER BY `uid` DESC LIMIT 1;''');
    if (fetchResult.isNotEmpty && fetchResult[0]['uid'] > 0) {
      return fetchResult[0]['uid'];
    }
    return 1;
  }

  CacheInfoModel? findBySymbol(String symbol) {
    final tableName = CacheInfoModel.tableName;
    final fetchResult = _db.select('''SELECT * FROM `$tableName` WHERE symbol = ? ;''', [symbol]);
    return fetchResult.isNotEmpty ? CacheInfoDaoUtil.rowConvertCacheInfoModel(fetchResult[0]) : null;
  }

  @override
  List<CacheInfoModel> fetchLocal() {
    final tableName = CacheInfoModel.tableName;
    final fetchResult = _db.select('''SELECT * FROM `$tableName` WHERE `uid` == 0 ;''');
    final List<CacheInfoModel> result = [];
    for (Row row in fetchResult) {
      result.add(CacheInfoDaoUtil.rowConvertCacheInfoModel(row));
    }

    return result;
  }
}
