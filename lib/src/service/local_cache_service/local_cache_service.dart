import 'dart:async';

import 'package:wuchuheng_imap_cache/src/model/cache_info_model/index.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

import '../../dao/db.dart';
import '../../utils/symbol_util/cache_symbol_util.dart';
import '../imap_cache_service/cache_abstract.dart';

class LocalCacheService implements CacheAbstract {
  final LocalSQLite _localSQLite;
  LocalCacheService(this._localSQLite);

  @override
  Future<String> get({required String key}) async {
    CacheInfoModel? cacheInfoModel = await _localSQLite.cacheInfoDao().findByKey(key: key);
    if (cacheInfoModel == null) {
      Logger.error("Not found local cache.key: $key");
      throw Error();
    }
    return cacheInfoModel.value;
  }

  @override
  Future<String?> has({required String key}) async {
    final hasData = await _localSQLite.cacheInfoDao().findByKey(key: key);
    if (hasData != null && hasData.deletedAt == null) return hasData.value;
    return null;
  }

  @override
  Future<void> set({required String key, required String value, DateTime? updatedAt}) async {
    Logger.info('Start setting up local cache. key: $key value: $value');
    updatedAt = updatedAt ?? DateTime.now();
    final cacheSymbolUtil = CacheSymbolUtil(updatedAt: updatedAt, key: key, value: value);
    String symbol = cacheSymbolUtil.toString();
    final cacheInfo = CacheInfoModel(
      updatedAt: updatedAt,
      symbol: symbol,
      value: value,
      uid: 0,
      key: key,
      hash: cacheSymbolUtil.hash,
    );
    await _localSQLite.cacheInfoDao().save(cacheInfo);
    Logger.info('Complete local cache settings. key $key value: $value');
  }

  @override
  Future<void> unset({required String key, DateTime? deletedAt}) async {
    final hasData = await _localSQLite.cacheInfoDao().findByKey(key: key);
    if (hasData != null) {
      hasData.deletedAt = deletedAt ?? DateTime.now();
      await _localSQLite.cacheInfoDao().save(hasData);
    }
  }
}
