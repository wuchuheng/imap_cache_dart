import 'package:drift/drift.dart';
import 'package:wuchuheng_imap_cache/src/dao/cache_info_dao/cache_info_dao_util.dart';
import 'package:wuchuheng_imap_cache/src/dao/cache_info_dao/index_abstract.dart';
import 'package:wuchuheng_imap_cache/src/model/cache_info_model/index.dart';

import '../db.dart';

class CacheInfoDao implements CacheInfoDaoAbstract {
  final DB localDB;

  CacheInfoDao({required DB DB}) : localDB = DB;

  @override
  Future<CacheInfoModel?> findByKey({required String key}) async {
    final CacheInfoData? item = await (localDB.select(localDB.cacheInfo)
          ..where((t) => t.key.equals(key))
          ..where((t) => t.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    final result = item == null ? null : cacheInfoDataToCacheInfoModel(item);
    return result;
  }

  @override
  Future<void> save(CacheInfoModel cacheInfo) async {
    final CacheInfoModel? hasCacheInfo = await findByKeyWithoutSoftDelete(key: cacheInfo.key);
    if (hasCacheInfo != null) {
      await (localDB.update(localDB.cacheInfo)..where((tbl) => tbl.key.equals(hasCacheInfo.key)))
          .write(CacheInfoCompanion(
        key: Value(cacheInfo.key),
        uid: Value(cacheInfo.uid),
        value: Value(cacheInfo.value),
        hash: Value(cacheInfo.hash),
        symbol: Value(cacheInfo.symbol),
        updatedAt: Value(cacheInfo.updatedAt),
        deletedAt: Value(cacheInfo.deletedAt),
      ));
      return;
    } else {
      await localDB.into(localDB.cacheInfo).insert(CacheInfoCompanion(
            key: Value(cacheInfo.key),
            uid: Value(cacheInfo.uid),
            value: Value(cacheInfo.value),
            hash: Value(cacheInfo.hash),
            symbol: Value(cacheInfo.symbol),
            updatedAt: Value(cacheInfo.updatedAt),
            deletedAt: Value(cacheInfo.deletedAt),
          ));
      return;
    }
  }

  Future<CacheInfoModel?> findBySymbol(String symbol) async {
    final item = await (localDB.select(localDB.cacheInfo)..where((tbl) => tbl.symbol.equals(symbol))).getSingleOrNull();
    if (item == null) return null;

    return cacheInfoDataToCacheInfoModel(item);
  }

  @override
  Future<List<CacheInfoModel>> fetchLocal() async {
    final List<CacheInfoData> items =
        await (localDB.select(localDB.cacheInfo)..where((tbl) => tbl.uid.equals(0))).get();
    return items.map((e) => cacheInfoDataToCacheInfoModel(e)).toList();
  }

  @override
  Future<CacheInfoModel?> findByKeyWithoutSoftDelete({required String key}) async {
    final CacheInfoData? item =
        await (localDB.select(localDB.cacheInfo)..where((tbl) => tbl.key.equals(key))).getSingleOrNull();
    if (item == null) return null;
    return cacheInfoDataToCacheInfoModel(item);
  }
}
