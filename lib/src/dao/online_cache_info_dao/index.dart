import 'package:drift/drift.dart';
import 'package:wuchuheng_imap_cache/src/dao/online_cache_info_dao/index_abstract.dart';
import 'package:wuchuheng_imap_cache/src/model/online_cache_info_model/index.dart';

import '../db.dart';
import 'online_cache_info_dao_util.dart';

class OnlineCacheInfoDao implements OnlineCacheInfoDaoAbstract {
  final DB localDB;
  OnlineCacheInfoDao({required DB DB}) : localDB = DB;

  Future<int> fetchLastUid() async {
    final OnlineCacheInfoData? item = await (localDB.select(localDB.onlineCacheInfo)
          ..orderBy([(t) => OrderingTerm(expression: t.uid, mode: OrderingMode.desc)])
          ..limit(1))
        .getSingleOrNull();

    return item != null ? item.uid : 1;
  }

  @override
  Future<OnlineCacheInfoModel> save(OnlineCacheInfoModel onlineCacheInfo) async {
    final OnlineCacheInfoModel? hasData = await findByKey(key: onlineCacheInfo.key);
    if (hasData != null) {
      await (localDB.update(localDB.onlineCacheInfo)..where((tbl) => tbl.key.equals(onlineCacheInfo.key)))
          .write(OnlineCacheInfoCompanion(
        hash: Value(onlineCacheInfo.hash),
        symbol: Value(onlineCacheInfo.symbol),
        updatedAt: Value(onlineCacheInfo.updatedAt),
        deletedAt: Value(onlineCacheInfo.deletedAt),
        uid: Value(onlineCacheInfo.uid),
      ));
    } else {
      await localDB.into(localDB.onlineCacheInfo).insert(OnlineCacheInfoCompanion(
            hash: Value(onlineCacheInfo.hash),
            symbol: Value(onlineCacheInfo.symbol),
            updatedAt: Value(onlineCacheInfo.updatedAt),
            deletedAt: Value(onlineCacheInfo.deletedAt),
            uid: Value(onlineCacheInfo.uid),
            key: Value(onlineCacheInfo.key),
          ));
    }

    return onlineCacheInfo;
  }

  @override
  Future<OnlineCacheInfoModel?> findByKey({required String key}) async {
    OnlineCacheInfoData? item = await (localDB.select(localDB.onlineCacheInfo)
          ..where((tbl) => tbl.key.equals(key))
          ..limit(1))
        .getSingleOrNull();
    return item != null ? onlineCacheInfoDataToCacheInfoModel(item) : null;
  }

  @override
  Future<List<OnlineCacheInfoModel>> fetch() async {
    CacheInfoData? item = await (localDB.select(localDB.cacheInfo)
          ..orderBy([(t) => OrderingTerm(expression: t.uid, mode: OrderingMode.desc)])
          ..limit(1))
        .getSingleOrNull();

    final localGreatUid = item != null && item.uid > 0 ? item.uid : 1;
    List<OnlineCacheInfoData> resultSet = await (localDB.select(localDB.onlineCacheInfo)
          ..where((tbl) => tbl.uid.isBiggerThanValue(localGreatUid))
          ..orderBy([(t) => OrderingTerm(expression: t.uid, mode: OrderingMode.desc)]))
        .get();

    return resultSet.map((e) => onlineCacheInfoDataToCacheInfoModel(e)).toList();
  }

  @override
  Future<void> destroyByUid(int uid) async =>
      await (localDB.delete(localDB.onlineCacheInfo)..where((tbl) => tbl.uid.equals(uid))).go();

  @override
  Future<List<OnlineCacheInfoModel>> fetchALLByKey(String key) async {
    final List<OnlineCacheInfoData> items =
        await (localDB.select(localDB.onlineCacheInfo)..where((tbl) => tbl.key.equals(key))).get();
    return items.map((e) => onlineCacheInfoDataToCacheInfoModel(e)).toList();
  }
}
