import 'package:sqlite3/sqlite3.dart';
import 'package:wuchuheng_imap_cache/src/dao/online_cache_info_dao/index_abstract.dart';
import 'package:wuchuheng_imap_cache/src/model/online_cache_info_model/index.dart';

import 'online_cache_info_dao_util.dart';

class OnlineCacheInfoDao implements OnlineCacheInfoDaoAbstract {
  final Database _db;

  OnlineCacheInfoDao({required Database db}) : _db = db;

  @override
  OnlineCacheInfoModel save(OnlineCacheInfoModel onlineCacheInfo) {
    final hasData = findByKey(key: onlineCacheInfo.key);
    final tableName = OnlineCacheInfoModel.tableName;
    if (hasData != null) {
      _db.execute('''
      UPDATE $tableName SET 
        `hash` = ?,
        `symbol` = ?,
        `updated_at` = ?,
        `deleted_at` = ?,
        `uid`= ?
        WHERE key ='${onlineCacheInfo.key}'
      ''', [
        onlineCacheInfo.hash,
        onlineCacheInfo.symbol,
        onlineCacheInfo.updatedAt.toString(),
        onlineCacheInfo.deletedAt?.toString(),
        onlineCacheInfo.uid,
      ]);
    } else {
      _db.execute('''
      INSERT INTO $tableName (
        `uid`, `key`, `hash`, `symbol`, `updated_at`, `deleted_at`
      ) VALUES (? , ?, ?, ?, ?,  ?) 
      
      ''', [
        onlineCacheInfo.uid,
        onlineCacheInfo.key,
        onlineCacheInfo.hash,
        onlineCacheInfo.symbol,
        onlineCacheInfo.updatedAt.toString(),
        onlineCacheInfo.deletedAt?.toString(),
      ]);
    }

    return onlineCacheInfo;
  }

  @override
  OnlineCacheInfoModel? findByKey({required String key}) {
    String tableName = OnlineCacheInfoModel.tableName;
    final ResultSet result = _db.select("select * from $tableName where `key` = ? Limit 1", [key]);
    if (result.isNotEmpty) {
      final Row row = result[0];
      return OnlineCacheInfoDaoUtil.rowConvertCacheInfoModel(row);
    }

    return null;
  }

  @override
  List<OnlineCacheInfoModel> fetch() {
    String tableName = OnlineCacheInfoModel.tableName;
    final ResultSet resultSet = _db.select("select * from $tableName ;");
    List<OnlineCacheInfoModel> result = [];
    if (resultSet.isNotEmpty) {
      for (var row in resultSet) {
        result.add(OnlineCacheInfoDaoUtil.rowConvertCacheInfoModel(row));
      }
    }
    return result;
  }

  @override
  void destroyAllData() => _db.execute("DELETE FROM ${OnlineCacheInfoModel.tableName};");

  @override
  void destroyByUid(int uid) => _db.execute('DELETE FROM ${OnlineCacheInfoModel.tableName} WHERE `uid` = $uid;');

  @override
  List<OnlineCacheInfoModel> fetchALLByKey(String key) {
    String tableName = OnlineCacheInfoModel.tableName;
    final ResultSet resultSet = _db.select("select * from $tableName WHERE `key` = ?  ;", [key]);
    List<OnlineCacheInfoModel> result = [];
    if (resultSet.isNotEmpty) {
      for (var row in resultSet) {
        result.add(OnlineCacheInfoDaoUtil.rowConvertCacheInfoModel(row));
      }
    }
    return result;
  }
}
