import 'package:sqlite3/sqlite3.dart';
import 'package:wuchuheng_imap_cache/src/dao/online_cache_info_dao/index_abstract.dart';
import 'package:wuchuheng_imap_cache/src/model/online_cache_info_model/index.dart';

import '../../model/cache_info_model/index.dart';
import '../db.dart';
import 'online_cache_info_dao_util.dart';

class OnlineCacheInfoDao implements OnlineCacheInfoDaoAbstract {
  final Database Function() getDb;
  final DB localDB;
  OnlineCacheInfoDao({required this.getDb, required DB DB}) : localDB = DB;

  int fetchLastUid() {
    final tableName = OnlineCacheInfoModel.tableName;
    final fetchResult = getDb().select('''SELECT `uid` FROM `$tableName` ORDER BY `uid` DESC LIMIT 1;''');
    if (fetchResult.isNotEmpty && fetchResult[0]['uid'] > 0) {
      return fetchResult[0]['uid'];
    }
    return 1;
  }

  @override
  OnlineCacheInfoModel save(OnlineCacheInfoModel onlineCacheInfo) {
    final hasData = findByKey(key: onlineCacheInfo.key);
    final tableName = OnlineCacheInfoModel.tableName;
    if (hasData != null) {
      getDb().execute('''
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
      getDb().execute('''
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
    final ResultSet result = getDb().select("select * from $tableName where `key` = ? Limit 1", [key]);
    if (result.isNotEmpty) {
      final Row row = result[0];
      return OnlineCacheInfoDaoUtil.rowConvertCacheInfoModel(row);
    }

    return null;
  }

  @override
  List<OnlineCacheInfoModel> fetch() {
    String tableName = OnlineCacheInfoModel.tableName;
    String localCacheInfoTableName = CacheInfoModel.tableName;
    final fetchResult = getDb().select('''SELECT `uid` FROM `$localCacheInfoTableName` ORDER BY `uid` DESC LIMIT 1;''');
    final localGreatUid = fetchResult.isNotEmpty && fetchResult[0]['uid'] > 0 ? fetchResult[0]['uid'] : 1;
    final ResultSet resultSet = getDb().select(
      "select * from $tableName where `uid` > $localGreatUid ORDER BY `uid` DESC LIMIT 1;",
    );
    List<OnlineCacheInfoModel> result = [];
    if (resultSet.isNotEmpty) {
      for (var row in resultSet) {
        result.add(OnlineCacheInfoDaoUtil.rowConvertCacheInfoModel(row));
      }
    }
    return result;
  }

  @override
  void destroyAllData() => getDb().execute("DELETE FROM ${OnlineCacheInfoModel.tableName};");

  @override
  void destroyByUid(int uid) => getDb().execute('DELETE FROM ${OnlineCacheInfoModel.tableName} WHERE `uid` = $uid;');

  @override
  List<OnlineCacheInfoModel> fetchALLByKey(String key) {
    String tableName = OnlineCacheInfoModel.tableName;
    final ResultSet resultSet = getDb().select("select * from $tableName WHERE `key` = ?  ;", [key]);
    List<OnlineCacheInfoModel> result = [];
    if (resultSet.isNotEmpty) {
      for (var row in resultSet) {
        result.add(OnlineCacheInfoDaoUtil.rowConvertCacheInfoModel(row));
      }
    }
    return result;
  }
}
