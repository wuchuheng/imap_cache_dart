import 'dart:async';

import 'package:wuchuheng_hooks/wuchuheng_hooks.dart' as hook;
import 'package:wuchuheng_imap_cache/src/dto/connect_config/index.dart';
import 'package:wuchuheng_imap_cache/src/service/imap_cache_service/index_abstarct.dart';
import 'package:wuchuheng_imap_cache/src/service/local_cache_service/local_cache_service.dart';
import 'package:wuchuheng_imap_cache/src/subscription/subscription_abstract.dart';
import 'package:wuchuheng_imap_cache/src/subscription/subscription_imp.dart';
import 'package:wuchuheng_imap_cache/src/subscription/unsubscribe.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

import '../../dao/local_sqlite.dart';
import '../sync_service/index.dart';
import '../sync_service/sync_service.dart';

class ImapCacheServiceI implements ImapCacheService {
  late LocalCacheService _localCacheService;
  late SubscriptionImp _subscriptionImp;
  late LocalSQLite _localSQLite;
  late SyncService _syncService;
  hook.UnsubscribeCollect unsubscribeCollect = hook.UnsubscribeCollect([]);

  /// connect to the IMAP server with user's account
  @override
  Future<ImapCacheService> connectToServer(ConnectConfig config) async {
    Logger.debugger = config.isDebug;
    _localSQLite = await LocalSQLite().init(userName: config.userName, localCacheDirectory: config.localCacheDirectory);
    _localCacheService = LocalCacheService(_localSQLite);
    _subscriptionImp = SubscriptionImp();
    _syncService = SyncServiceI(config, _localSQLite, this);
    await _syncService.start();
    unsubscribeCollect = hook.UnsubscribeCollect([
      _syncService.afterSync(afterSyncSubject.next),
      _syncService.beforeSync(beforeSyncSubject.next),
    ]);
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

  @override
  UnsubscribeAbstract subscribeLog(void Function(LoggerItem loggerItem) callback) {
    final subscribe = Logger.subscribe((value) {
      callback(value);
    });

    return Unsubscribe(() {
      subscribe.unsubscribe();
    });
  }

  @override
  Future<void> disconnect() async {
    await _syncService.stop();
    unsubscribeCollect.unsubscribe();
  }

  hook.SubjectHook<Duration> afterSyncSubject = hook.SubjectHook();
  hook.SubjectHook<Duration> beforeSyncSubject = hook.SubjectHook();

  @override
  hook.Unsubscribe afterSync(void Function(Duration duration) callback) => afterSyncSubject.subscribe(callback);

  @override
  hook.Unsubscribe beforeSync(void Function(Duration duration) callback) => beforeSyncSubject.subscribe(callback);

  @override
  Future<void> setSyncInterval(int second) async => await _syncService.setSyncInterval(second);
}
