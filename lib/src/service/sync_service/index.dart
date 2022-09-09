import 'dart:async';

import 'package:wuchuheng_hooks/wuchuheng_hooks.dart';
import 'package:wuchuheng_imap_cache/src/dao/local_sqlite.dart';
import 'package:wuchuheng_imap_cache/src/service/imap_client_service/index.dart';
import 'package:wuchuheng_imap_cache/src/service/imap_directory_service/index.dart';
import 'package:wuchuheng_imap_cache/src/service/sync_service/online_sync_to_local_service/index.dart';
import 'package:wuchuheng_imap_cache/src/service/sync_service/sync_service.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

import '../../dto/connect_config/index.dart';
import '../imap_cache_service/index.dart';
import 'sync_event.dart';

class SyncServiceI implements SyncService {
  late ImapDirectoryService _imapDirectoryService;
  final ConnectConfig _config;
  final LocalSQLite _localSQLite;
  final ImapCacheServiceI _imapCache;
  final beforeStartSubject = SubjectHook<Duration>();
  final afterCompletedSubject = SubjectHook<Duration>();
  bool _isInit = false;
  bool _isRunning = false;
  late Duration _syncDurationSeconds;
  late ImapClientService _imapClientService;
  SyncServiceI(this._config, this._localSQLite, this._imapCache) {
    _syncDurationSeconds = Duration(seconds: _config.syncDurationSeconds);
  }

  Future<void> _init(ConnectConfig config) async {
    _imapClientService = ImapClientService(
      userName: config.userName,
      password: config.password,
      imapServerHost: config.imapServerHost,
      imapServerPort: config.imapServerPort,
      isImapServerSecure: config.isImapServerSecure,
    );
    final imapDirectoryService = ImapDirectoryService(
      path: config.boxName,
      imapClientService: _imapClientService,
      localSQLite: _localSQLite,
    );
    _imapDirectoryService = imapDirectoryService;
    if (!await _imapDirectoryService.exists()) {
      await _imapDirectoryService.create();
      await Future.delayed(_syncDurationSeconds);
    }
  }

  /// Start synchronizing data
  @override
  Future<void> start() async {
    _isRunning = true;
    Completer<void> completer = Completer();
    if (!_isInit) {
      await _init(_config);
      _isInit = true;
      completer.complete();
      await _imapDirectoryService.selectPath();
    }
    syncData() async {
      if (!_isRunning) return;
      try {
        beforeStartSubject.next(_syncDurationSeconds);
        await OnlineSyncToLocalServiceI(
          imapDirectoryService: _imapDirectoryService,
          localSQLite: _localSQLite,
          imapCache: _imapCache,
        ).start();
        afterCompletedSubject.next(_syncDurationSeconds);
      } catch (e) {
        Logger.error(e.toString());
      }
      Timer(Duration(seconds: 5), () async {
        await syncData();
      });
    }

    syncData();

    return completer.future;
  }

  @override
  Future<void> stop() async {
    _isRunning = false;
    _isInit = false;
    final client = await _imapClientService.getClient();
    client.disconnect();
    Logger.info('Stop data synchronization');
  }

  @override
  Unsubscribe afterSync(AfterSyncCallback callback) => afterCompletedSubject.subscribe(callback);

  @override
  Unsubscribe beforeSync(BeforeSyncCallback callback) {
    return beforeStartSubject.subscribe((value) {
      callback(value);
    });
  }
}
