import 'package:imap_cache/src/dao/cache_info_dao/cache_info_dao_util.dart';
import 'package:imap_cache/src/dao/cache_info_dao/index_abstract.dart';
import 'package:imap_cache/src/model/cache_info_model/index.dart';
import 'package:imap_cache/src/utils/symbol_util/cache_symbol_util.dart';
import 'package:sqlite3/sqlite3.dart';

class CacheInfoDao implements CacheInfoDaoAbstract {
  final Database _db;

  CacheInfoDao({required Database db}) : _db = db;

  @override
  void set({required String key, required String value}) {
    final hasCacheInfo = has(key: key);
    final updatedAt = DateTime.now();
    final cacheSymbolUtil = CacheSymbolUtil(updatedAt: updatedAt, key: key, value: value);
    String symbol = cacheSymbolUtil.toString();
    final cacheInfo = CacheInfoModel(
      updatedAt: updatedAt,
      symbol: symbol,
      uid: null,
      value: value,
      key: key,
      hash: cacheSymbolUtil.hash,
    );
    final tableName = CacheInfoModel.tableName;
    if (hasCacheInfo != null) {
      _db.execute('''
      UPDATE $tableName SET 
        `value` = ?,
        `hash` = ?,
        `symbol` = ?,
        `updated_at` = ?,
        `deleted_at` = null 
        WHERE key ='${cacheInfo.key}'
      ''', [cacheInfo.value, cacheInfo.hash, cacheInfo.symbol, cacheInfo.updatedAt.toString()]);
    } else {
      _db.execute('''
      INSERT INTO $tableName (
        `uid`, `key`, `value`, `hash`, `symbol`, `updated_at`, `deleted_at`
      ) VALUES ( null, ?, ?, ?, ?, ?, null ) 
    ''', [cacheInfo.key, cacheInfo.value, cacheInfo.hash, cacheInfo.symbol, cacheInfo.updatedAt.toString()]);
    }
  }

  @override
  CacheInfoModel? has({required String key}) {
    String tableName = CacheInfoModel.tableName;
    final ResultSet result = _db.select("select * from $tableName where key = '$key' Limit 1");
    if (result.isNotEmpty) {
      final Row row = result[0];
      return CacheInfoDaoUtil.rowConvertCacheInfoModel(row);
    }

    return null;
  }
}
