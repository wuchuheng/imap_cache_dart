import 'dart:async';

import 'package:imap_cache/src/dto/connect_config/index.dart';
import 'package:imap_cache/src/service/imap_cache_service/index_abstarct.dart';
import 'package:imap_cache/src/service/local_cache_service/local_cache_service.dart';
import 'package:imap_cache/src/subscription/subscription_abstract.dart';
import 'package:imap_cache/src/subscription/subscription_imp.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

import '../../dao/local_sqlite.dart';
import '../sync_service/index.dart';

class ImapCacheService implements ImapCacheServiceAbstract {
  late LocalCacheService _localCacheService;
  late SubscriptionImp _subscriptionImp;
  late LocalSQLite _localSQLite;

  /// connect to the IMAP server with user's account
  @override
  Future<ImapCacheServiceAbstract> connectToServer(ConnectConfig config) async {
    Logger.debugger = config.isDebug;
    _localSQLite = await LocalSQLite().init(userName: config.userName, localCacheDirectory: config.localCacheDirectory);
    _localCacheService = LocalCacheService(_localSQLite);
    _subscriptionImp = SubscriptionImp();
    await SyncService(config, _localSQLite, this).start();
    return this;
  }

  @override
  Future<void> set({required String key, required String value}) async {
    Logger.info('Before setting the cache. key:$key value: $value');
    value = await _subscriptionImp.beforeSetSubscribeConsume(key: key, value: value);
    _localCacheService.set(key: key, value: value);
    _subscriptionImp.afterSetSubscribeConsume(key: key, value: value);
    Logger.info('After setting the cache. key:$key value: $value');
  }

  @override
  Future<bool> unset({required String key}) async {
    Logger.info('Before unsetting the cache. key:$key');
    if (!await _subscriptionImp.beforeUnsetConsume(key: key)) {
      Logger.info('Failed to unset key: $key');
      return false;
    }
    _localCacheService.unset(key: key);
    _subscriptionImp.afterUnsetSubscribeConsume(key: key);
    Logger.info('After unsetting the cache. key:$key');
    return true;
  }

  @override
  Future<String> get({required String key}) => _localCacheService.get(key: key);

  @override
  Future<String?> has({required String key}) => _localCacheService.has(key: key);

  @override
  UnsubscribeAbstract afterUnset({String? key, required AfterUnsetCallback callback}) =>
      _subscriptionImp.afterUnset(key: key, callback: callback);

  @override
  UnsubscribeAbstract beforeUnset({String? key, required BeforeUnsetCallback callback}) =>
      _subscriptionImp.beforeUnset(key: key, callback: callback);

  @override
  UnsubscribeAbstract afterSet({String? key, required AfterSetCallback callback}) =>
      _subscriptionImp.afterSet(key: key, callback: callback);

  @override
  UnsubscribeAbstract beforeSet({String? key, required BeforeSetCallback callback}) =>
      _subscriptionImp.beforeSet(key: key, callback: callback);
}
