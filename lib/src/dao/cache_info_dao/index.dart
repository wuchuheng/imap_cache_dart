import 'package:sqlite3/sqlite3.dart';
import 'package:wuchuheng_imap_cache/src/dao/cache_info_dao/cache_info_dao_util.dart';
import 'package:wuchuheng_imap_cache/src/dao/cache_info_dao/index_abstract.dart';
import 'package:wuchuheng_imap_cache/src/model/cache_info_model/index.dart';

class CacheInfoDao implements CacheInfoDaoAbstract {
  final Database _db;

  CacheInfoDao({required Database db}) : _db = db;

  @override
  CacheInfoModel? findByKey({required String key}) {
    String tableName = CacheInfoModel.tableName;
    final sql = "select * from `$tableName` where `key` = '$key' AND deleted_at is null Limit 1 ";
    final ResultSet result = _db.select(sql);
    if (result.isNotEmpty) {
      final Row row = result[0];
      return CacheInfoDaoUtil.rowConvertCacheInfoModel(row);
    }

    return null;
  }

  @override
  void save(CacheInfoModel cacheInfo) {
    final hasCacheInfo = findByKeyWithoutSoftDelete(key: cacheInfo.key);
    final tableName = CacheInfoModel.tableName;
    if (hasCacheInfo != null) {
      String? deletedAt = cacheInfo.deletedAt != null ? cacheInfo.deletedAt!.toString() : null;
      _db.execute('''
      UPDATE $tableName SET 
        value = ?,
        hash = '${cacheInfo.hash}',
        symbol = '${cacheInfo.symbol}',
        updated_at = '${cacheInfo.updatedAt.toString()}',
        deleted_at = ?,
        uid = ${cacheInfo.uid}
        WHERE key = '${cacheInfo.key}'
      ''', [cacheInfo.value, deletedAt]);
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

  @override
  CacheInfoModel? findByKeyWithoutSoftDelete({required String key}) {
    String tableName = CacheInfoModel.tableName;
    final sql = "select * from `$tableName` where `key` = '$key'";
    final ResultSet result = _db.select(sql);
    if (result.isNotEmpty) {
      final Row row = result[0];
      return CacheInfoDaoUtil.rowConvertCacheInfoModel(row);
    }

    return null;
  }
}
