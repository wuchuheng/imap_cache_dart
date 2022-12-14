import 'dart:async';

import 'package:wuchuheng_hooks/wuchuheng_hooks.dart';
import 'package:wuchuheng_imap_cache/src/service/imap_client_service/index.dart';
import 'package:wuchuheng_imap_cache/src/service/imap_directory_service/index.dart';
import 'package:wuchuheng_imap_cache/src/service/sync_service/sync_service_abstract.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

import '../../dao/db.dart';
import '../../dto/connect_config/index.dart';
import '../imap_cache_service/imap_cache_service.dart';
import 'IMAP_sync_service/index.dart';
import 'sync_event.dart';

/// 同步状态
enum SyncStatus {
  processing,
  pending,
}

class SyncServiceI implements SyncService {
  late ImapDirectoryService _imapDirectoryService;
  final ConnectConfig _config;
  final LocalSQLite _localSQLite;
  late final ImapCacheServiceI _imapCache;
  final beforeStartSubject = SubjectHook<Duration>();
  final afterCompletedSubject = SubjectHook<Duration>();
  final onUpdateSubject = SubjectHook<void>();
  final onUpdatedSubject = SubjectHook<void>();
  final onDownloadSubject = SubjectHook<void>();
  final onDownloadedSubject = SubjectHook<void>();
  bool _isInit = false;
  bool _isRunning = false;
  late ImapClientService _imapClientService;
  late int _syncIntervalSeconds;
  Completer<void> _syncBlock = Completer();
  Timer? _syncTimer;
  SyncStatus _syncStatus = SyncStatus.pending;

  SyncServiceI(this._config, this._localSQLite, this._imapCache) {
    _syncIntervalSeconds = _config.syncIntervalSeconds;
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
      await Future.delayed(Duration(seconds: 5));
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
        _syncStatus = SyncStatus.processing;
        beforeStartSubject.next(Duration(seconds: _syncIntervalSeconds));
        await IMAPSyncServiceI(
          imapDirectoryService: _imapDirectoryService,
          localSQLite: _localSQLite,
          imapCache: _imapCache,
          onUpdate: () => onUpdateSubject.next(null),
          onUpdated: () => onUpdatedSubject.next(null),
          onDownload: () => onDownloadSubject.next(null),
          onDownloaded: () => onDownloadedSubject.next(null),
        ).start();
        afterCompletedSubject.next(Duration(seconds: _syncIntervalSeconds));
      } catch (e, stack) {
        Logger.error(e.toString());
        try {
          Logger.info('Try to re-establish the connection.');
          _imapCache.disconnect();
          await Future.delayed(Duration(seconds: 1));
          await _imapCache.connectToServer(_config);
        } catch (e) {
          Logger.error('Retry connection failed.');
          // TODO: the callback that triggered the connection failure is reported here.
        }
      }
      _syncBlock = Completer();
      _syncTimer?.cancel();
      _syncTimer = Timer(Duration(seconds: _syncIntervalSeconds), () => _syncBlock.complete());
      _syncStatus = SyncStatus.pending;
      await _syncBlock.future;
      await syncData();
    }

    syncData();

    return completer.future;
  }

  @override
  Future<void> stop() async {
    _isRunning = false;
    _syncTimer?.cancel();
    _isInit = false;
    final client = await _imapClientService.getClient();
    client.disconnect();
    Logger.info('Stop data synchronization');
  }

  @override
  Unsubscribe afterSync(AfterSyncCallback callback) => afterCompletedSubject.subscribe((v, _) => callback(v));

  @override
  Unsubscribe beforeSync(BeforeSyncCallback callback) {
    return beforeStartSubject.subscribe((value, cancel) => callback(value));
  }

  @override
  Future<void> setSyncInterval(int second) async => _syncIntervalSeconds = second;

  @override
  Unsubscribe onUpdate(void Function() callback) => onUpdateSubject.subscribe((value, _) => callback());

  @override
  Unsubscribe onUpdated(void Function() callback) => onUpdatedSubject.subscribe((value, _) => callback());

  @override
  Unsubscribe onDownload(void Function() callback) => onDownloadSubject.subscribe((value, _) => callback());

  @override
  Unsubscribe onDownloaded(void Function() callback) => onDownloadedSubject.subscribe((value, _) => callback());

  @override
  void refresh() {
    if (_syncStatus == SyncStatus.pending) {
      Logger.info('Refresh data synchronization.');
      _syncTimer?.cancel();
      _syncBlock.complete();
    }
  }
}
