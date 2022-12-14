import 'dart:async';

import 'package:wuchuheng_hooks/wuchuheng_hooks.dart' as hook;
import 'package:wuchuheng_hooks/wuchuheng_hooks.dart';
import 'package:wuchuheng_imap_cache/src/dto/connect_config/index.dart';
import 'package:wuchuheng_imap_cache/src/service/imap_cache_service/index_abstarct.dart';
import 'package:wuchuheng_imap_cache/src/service/local_cache_service/local_cache_service.dart';
import 'package:wuchuheng_imap_cache/src/subscription/subscription_abstract.dart';
import 'package:wuchuheng_imap_cache/src/subscription/subscription_imp.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

import '../../dao/db.dart';
import '../sync_service/sync_service.dart';
import '../sync_service/sync_service_abstract.dart';

class ImapCacheServiceI implements ImapCacheService {
  hook.SubjectHook<Duration> afterSyncSubject = hook.SubjectHook();
  hook.SubjectHook<Duration> beforeSyncSubject = hook.SubjectHook();
  hook.SubjectHook<void> onUpdateSubject = hook.SubjectHook();
  hook.SubjectHook<void> onCompleteUpdateSubject = hook.SubjectHook();
  hook.SubjectHook<void> onDownloadSubject = hook.SubjectHook();
  hook.SubjectHook<void> onDownloadedSubject = hook.SubjectHook();
  hook.UnsubscribeCollect unsubscribeCollect = hook.UnsubscribeCollect([]);

  late LocalCacheService _localCacheService;
  late SubscriptionImp _subscriptionImp;
  late LocalSQLite _localSQLite;
  late SyncService _syncService;
  Map<String, DateTime> keyMapUpdatedAt = {};

  /// connect to the IMAP server with user's account
  @override
  Future<ImapCacheService> connectToServer(ConnectConfig config) async {
    Logger.debugger = config.isDebug;
    final _DB = DB(
      DBStoreDir: '${config.localCacheDirectory}/localCache/${config.userName}',
      logStatements: config.isDebug,
    );
    _localSQLite = LocalSQLite(_DB);
    _localCacheService = LocalCacheService(_localSQLite);
    _subscriptionImp = SubscriptionImp();
    _syncService = SyncServiceI(config, _localSQLite, this);
    await _syncService.start();
    unsubscribeCollect = hook.UnsubscribeCollect([
      _syncService.afterSync(afterSyncSubject.next),
      _syncService.beforeSync(beforeSyncSubject.next),
      _syncService.onUpdate(() => onUpdateSubject.next(null)),
      _syncService.onUpdated(() => onCompleteUpdateSubject.next(null)),
      _syncService.onDownload(() => onDownloadSubject.next(null)),
      _syncService.onDownloaded(() => onDownloadedSubject.next(null)),
    ]);
    return this;
  }

  @override
  Future<void> set({required String key, required String value}) async =>
      await setWithFrom(key: key, value: value, from: From.local);

  Future<void> setWithFrom({required String key, required String value, required From from}) async {
    Logger.info('Before setting the cache. key:$key value: $value');
    value = await _subscriptionImp.beforeSetSubscribeConsume(key: key, value: value, from: from);
    final DateTime updatedAt = DateTime.now();
    await _localCacheService.set(key: key, value: value, updatedAt: updatedAt);
    _subscriptionImp.afterSetSubscribeConsume(key: key, value: value, from: from);
    keyMapUpdatedAt[key] = updatedAt;
    if (from == From.local) _syncService.refresh();
    Logger.info('After setting the cache. key:$key value: $value');
  }

  @override
  Future<bool> unset({required String key}) async {
    Logger.info('Before unsetting the cache. key:$key');
    if (!await _subscriptionImp.beforeUnsetConsume(key: key)) {
      Logger.info('Failed to unset key: $key');
      return false;
    }
    final DateTime deletedAt = DateTime.now();
    await _localCacheService.unset(key: key, deletedAt: deletedAt);
    _subscriptionImp.afterUnsetSubscribeConsume(key: key);
    keyMapUpdatedAt[key] = deletedAt;
    Logger.info('After unsetting the cache. key:$key');
    return true;
  }

  @override
  Future<String> get({required String key}) => _localCacheService.get(key: key);

  @override
  Future<String?> has({required String key}) => _localCacheService.has(key: key);

  @override
  hook.Unsubscribe afterUnset({String? key, required AfterUnsetCallback callback}) =>
      _subscriptionImp.afterUnset(key: key, callback: callback);

  @override
  hook.Unsubscribe beforeUnset({String? key, required BeforeUnsetCallback callback}) =>
      _subscriptionImp.beforeUnset(key: key, callback: callback);

  @override
  hook.Unsubscribe afterSet({String? key, required AfterSetCallback callback}) =>
      _subscriptionImp.afterSet(key: key, callback: callback);

  @override
  hook.Unsubscribe beforeSet({String? key, required BeforeSetCallback callback}) =>
      _subscriptionImp.beforeSet(key: key, callback: callback);

  @override
  hook.Unsubscribe subscribeLog(void Function(LoggerItem loggerItem) callback) {
    final subscribe = Logger.subscribe((value, _) {
      callback(value);
    });

    return Unsubscribe(() {
      subscribe.unsubscribe();
      return true;
    });
  }

  @override
  Future<void> disconnect() async {
    await _syncService.stop();
    unsubscribeCollect.unsubscribe();
  }

  @override
  hook.Unsubscribe afterSync(void Function(Duration duration) callback) =>
      afterSyncSubject.subscribe((v, _) => callback(v));

  @override
  hook.Unsubscribe beforeSync(void Function(Duration duration) callback) =>
      beforeSyncSubject.subscribe((v, _) => callback(v));

  @override
  Future<void> setSyncInterval(int second) async => await _syncService.setSyncInterval(second);

  @override
  hook.Unsubscribe onUpdate(void Function() callback) => onUpdateSubject.subscribe((value, _) => callback());

  @override
  hook.Unsubscribe onUpdated(void Function() callback) => onCompleteUpdateSubject.subscribe((value, _) => callback());

  @override
  hook.Unsubscribe onDownload(void Function() callback) => onDownloadSubject.subscribe((value, _) => callback());

  @override
  hook.Unsubscribe onDownloaded(void Function() callback) => onDownloadedSubject.subscribe((value, _) => callback());
}
