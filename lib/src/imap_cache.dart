import 'dart:async';
import 'dart:io';

import 'package:imap_cache/src/cache_common_config.dart';
import 'package:imap_cache/src/cache_io_abstract.dart';
import 'package:imap_cache/src/cache_service_abstract.dart';
import 'package:imap_cache/src/errors/not_found_imap_service_error.dart';
import 'package:imap_cache/src/errors/not_found_register_error.dart';
import 'package:imap_cache/src/imap_service/imap_service.dart';
import 'package:imap_cache/src/imap_service/register_service.dart';
import 'package:imap_cache/src/local_cache_service/local_cache_register_service.dart';
import 'package:imap_cache/src/subscription/subscription_abstract.dart';
import 'package:imap_cache/src/subscription/sync_event_subscription_abstract.dart';
import 'package:imap_cache/src/sync_data.dart';
import 'package:imap_cache/src/utils/logger.dart';
import 'package:imap_cache/src/utils/single_task_pool.dart';

import 'local_cache_service/local_cache_service.dart';
import 'subscription/unsubscribe.dart'; // for the utf8.encode method

class ImapCache implements ImapServiceAbstract, SubscriptionFactoryAbstract, SyncEventSubscriptionAbstract {
  static late int _syncIntervalSeconds;
  final SingleTaskPool _limitSyncTaskPool = SingleTaskPool();
  bool _isSyncing = false;
  final Map<String, Map<int, void Function(String value)>> _setEventCallbackList = {};
  final Map<String, Map<int, void Function({required String key})>> _unsetEventCallbackList = {};
  final Map<int, void Function()> _completeSyncEventList = {};
  final Map<int, void Function()> _startSyncEventList = {};
  final Map<String, Map<int, Future<String> Function({required String onlineValue})>>
      beforeOnlineModifyLocalCallbackList = {};
  ImapService? _imapService;
  RegisterService? _registerService;
  RegisterService _getRegister() {
    if (_registerService == null) throw NotFoundRegisterError();
    return _registerService!;
  }

  ImapService _getImapService() {
    if (_imapService == null) throw NotFoundImapServiceError();
    return _imapService!;
  }

  /// Synchronize online and local data
  Future<void> _syncOnline() async {
    Logger.info("Start synchronizing data");
    try {
      Future.wait([_hookStartSyncEvent()]);
      // init onlineData
      RegisterService registerService = _getRegister();
      RegisterInfo? hasRegisterInfo = await registerService.hasRegister();
      if (hasRegisterInfo == null) {
        final RegisterInfo initData = RegisterInfo(uidMapKey: {}, data: {});
        await registerService.setRegister(data: initData);
        hasRegisterInfo = initData;
      }
      RegisterInfo onlineRegister = hasRegisterInfo;
      RegisterInfo localRegister = await LocalCacheRegisterService().getRegister();
      List<String> onlineKeys = onlineRegister.data.keys.toList();
      List<String> localKeys = localRegister.data.keys.toList();
      List<String> allKeys = onlineKeys;
      for (String e in localKeys) {
        if (!onlineKeys.contains(e)) onlineKeys.add(e);
      }
      for (String key in allKeys) {
        await SyncData.onlineExistAndLocalNone(
          onlineRegisterInfo: onlineRegister,
          localRegisterInfo: localRegister,
          imapService: _getImapService(),
          key: key,
          imapCache: this,
        );
        await SyncData.onlineExistAndLocalExist(
            onlineRegisterInfo: onlineRegister,
            localRegisterInfo: localRegister,
            imapService: _getImapService(),
            imapCache: this,
            key: key);
        await SyncData.onlineNoneAndLocalExist(
            onlineRegisterInfo: onlineRegister,
            imapService: _getImapService(),
            localRegisterInfo: localRegister,
            key: key);
      }
      Logger.info('Completed data synchronization.');
      Future.wait([_hookCompletedSyncEvent()]);
    } on SocketException catch (e, stacktrace) {
      print(e);
      print(stacktrace);
    } catch (e) {
      rethrow;
    } finally {
      await Future.delayed(Duration(seconds: _syncIntervalSeconds));
      Logger.info("Synchronization of completed data");
      _syncOnline().then((value) => {});
    }
  }

  /// connect to the IMAP server with user's account
  Future<ImapCache> connectToServer({
    required String userName,
    required String password,
    required String imapServerHost,
    required int imapServerPort,
    required bool isImapServerSecure,
    required String boxName,
    int syncIntervalSeconds = 5,
    bool isShowLog = false,
  }) async {
    _syncIntervalSeconds = syncIntervalSeconds;
    Logger.isShowLog = isShowLog;
    String registerMailBox = '${boxName}_register';
    _registerService = await RegisterService().connectToServer(
        userName: userName,
        password: password,
        imapServerHost: imapServerHost,
        imapServerPort: imapServerPort,
        isImapServerSecure: isImapServerSecure,
        boxName: boxName,
        registerMailBox: registerMailBox);
    _imapService = await ImapService(registerService: _getRegister()).connectToServer(
      userName: userName,
      password: password,
      imapServerHost: imapServerHost,
      imapServerPort: imapServerPort,
      isImapServerSecure: isImapServerSecure,
      boxName: boxName,
      registerMailBox: registerMailBox,
      registerService: _registerService!,
    );
    CacheCommonConfig.userName = userName;
    await _limitSyncTaskPool.start(() async {
      if (!_isSyncing) {
        _isSyncing = true;
        _syncOnline();
      }
    },);

    return this;
  }

  @override
  Future<void> set({
    required String key,
    required String value,
  }) async {
    await LocalCacheService().set(key: key, value: value);
    Future.wait([_hookSetEvents(key: key, value: value)]);
  }

  Future<void> _hookSetEvents({
    required String key,
    required String value,
  }) async {
    if (_setEventCallbackList[key] != null && _setEventCallbackList[key]!.isNotEmpty) {
      for (final callback in _setEventCallbackList[key]!.values) {
        callback(value);
      }
    }
  }

  @override
  Future<void> unset({required String key}) async {
    LocalCacheService().unset(key: key);
    Future.wait([_hookUnsetEvents(key: key)]);
  }

  Future<void> _hookUnsetEvents({required String key}) async {
    if (_unsetEventCallbackList[key] != null && _unsetEventCallbackList[key]!.isNotEmpty) {
      for (final callback in _unsetEventCallbackList[key]!.values) {
        callback(key: key);
      }
    }
  }

  @override
  Future<String> get({required String key}) => LocalCacheService().get(key: key);

  @override
  Future<bool> has({required String key}) => LocalCacheService().has(key: key);

  @override
  UnsubscribeAbstract completedSyncEvent(void Function() callback) {
    int id = DateTime.now().microsecondsSinceEpoch;
    _completeSyncEventList[id] = callback;
    return Unsubscription(() => _completeSyncEventList.remove(id));
  }

  Future<void> _hookCompletedSyncEvent() async {
    if (_completeSyncEventList.isNotEmpty) {
      _completeSyncEventList.forEach((_, value) => value());
    }
  }

  Future<void> _hookStartSyncEvent() async {
    if (_startSyncEventList.isNotEmpty) {
      _startSyncEventList.forEach((_, value) => value());
    }
  }

  @override
  UnsubscribeAbstract startSyncEvent(void Function() callback) {
    int id = DateTime.now().microsecondsSinceEpoch;
    _startSyncEventList[id] = callback;

    return Unsubscription(() => _startSyncEventList.remove(id));
  }

  @override
  UnsubscribeAbstract setEventSubscribe({required String key, required void Function(String value) callback}) {
    int id = DateTime.now().microsecondsSinceEpoch;
    if (_setEventCallbackList[key] == null) _setEventCallbackList[key] = {};
    _setEventCallbackList[key]![id] = callback;

    return Unsubscription(() => _setEventCallbackList[key]!.remove(id));
  }

  @override
  UnsubscribeAbstract unsetEventSubscribe(
      {required String key, required void Function({required String key}) callback}) {
    int id = DateTime.now().microsecondsSinceEpoch;
    if (_unsetEventCallbackList[key] == null) _unsetEventCallbackList[key] = {};
    _unsetEventCallbackList[key]![id] = callback;

    return Unsubscription(() => _unsetEventCallbackList[key]!.remove(id));
  }

  @override
  UnsubscribeAbstract beforeOnlineModifyLocalEvent(
      {required String key, required Future<String> Function({required String onlineValue}) callback}) {
    if (beforeOnlineModifyLocalCallbackList[key] == null) {
      beforeOnlineModifyLocalCallbackList[key] = {};
    }
    int id = DateTime.now().microsecondsSinceEpoch;
    beforeOnlineModifyLocalCallbackList[key]![id] = callback;

    return Unsubscription(() => beforeOnlineModifyLocalCallbackList[key]!.remove(id));
  }
}
