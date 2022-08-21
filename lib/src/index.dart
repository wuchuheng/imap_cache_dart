import 'dart:async';

import 'package:imap_cache/src/cache_service_abstract.dart';
import 'package:imap_cache/src/model/connect_config/index.dart';
import 'package:imap_cache/src/service/local_cache_service/local_cache_service.dart';
import 'package:imap_cache/src/service/sync_service/index.dart';
import 'package:imap_cache/src/subscription/subscription_abstract.dart';
import 'package:imap_cache/src/subscription/subscription_imp.dart';
import 'package:imap_cache/src/subscription/sync_event_subscription_abstract.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

import 'dao/local_sqlite.dart';

class ImapCache implements ImapServiceAbstract, SubscriptionAbstract, SyncEventSubscriptionAbstract {
  late LocalCacheService _localCacheService;
  late SubscriptionImp _subscriptionImp;
  late LocalSQLite _localSQLite;

  /// connect to the IMAP server with user's account
  Future<ImapCache> connectToServer({
    required String userName,
    required String password,
    required String imapServerHost,
    required int imapServerPort,
    required bool isImapServerSecure,
    required String boxName,
    int syncIntervalSeconds = 5,
    bool isDebug = false,
  }) async {
    Logger.debugger = isDebug;
    _localSQLite = await LocalSQLite().init(userName: userName);
    _localCacheService = LocalCacheService(_localSQLite);
    _subscriptionImp = SubscriptionImp();
    ConnectConfig config = ConnectConfig(
      userName: userName,
      password: password,
      imapServerHost: imapServerHost,
      imapServerPort: imapServerPort,
      isImapServerSecure: isImapServerSecure,
      boxName: boxName,
      syncIntervalSeconds: syncIntervalSeconds,
      isDebug: isDebug,
    );
    SyncService(config, _localSQLite, this).start();
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
