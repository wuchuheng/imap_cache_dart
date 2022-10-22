import 'dart:async';

import 'package:wuchuheng_imap_cache/src/dao/local_sqlite.dart';
import 'package:wuchuheng_imap_cache/src/model/cache_info_model/index.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

import '../../utils/symbol_util/cache_symbol_util.dart';
import '../imap_cache_service/cache_abstract.dart';

class LocalCacheService implements CacheAbstract {
  /// todo delete
  final LocalSQLite _localSQLite;
  LocalCacheService(this._localSQLite);

  @override
  Future<String> get({required String key}) async {
    CacheInfoModel? cacheInfoModel = _localSQLite.cacheInfoDao().findByKey(key: key);
    if (cacheInfoModel == null) {
      Logger.error("Not found local cache.key: $key");
      throw Error();
    }
    return cacheInfoModel.value;
  }

  @override
  Future<String?> has({required String key}) async {
    final hasData = _localSQLite.cacheInfoDao().findByKey(key: key);
    if (hasData != null && hasData.deletedAt == null) return hasData.value;
    return null;
  }

  @override
  Future<void> set({required String key, required String value}) async {
    Logger.info('Start setting up local cache. key: $key value: $value');
    final updatedAt = DateTime.now();
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
    _localSQLite.cacheInfoDao().save(cacheInfo);
    Logger.info('Complete local cache settings. key $key value: $value');
  }

  @override
  Future<void> unset({required String key}) async {
    final hasData = _localSQLite.cacheInfoDao().findByKey(key: key);
    if (hasData != null) {
      hasData.deletedAt = DateTime.now();
      _localSQLite.cacheInfoDao().save(hasData);
    }
  }
}
