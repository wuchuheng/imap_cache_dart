import 'dart:async';

import 'package:imap_cache/src/dao/local_sqlite.dart';
import 'package:imap_cache/src/service/imap_client_service/index.dart';
import 'package:imap_cache/src/service/imap_directory_service/index.dart';
import 'package:imap_cache/src/service/sync_service/online_sync_to_local_serevice.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

import '../../dto/connect_config/index.dart';
import '../imap_cache_service/index.dart';

class SyncService {
  late ImapDirectoryService _imapDirectoryService;
  final ConnectConfig _config;
  final LocalSQLite _localSQLite;
  final ImapCacheService _imapCache;
  bool _isInit = false;

  SyncService(this._config, this._localSQLite, this._imapCache);

  Future<void> _init(ConnectConfig config) async {
    final imapClientService = ImapClientService(
      userName: config.userName,
      password: config.password,
      imapServerHost: config.imapServerHost,
      imapServerPort: config.imapServerPort,
      isImapServerSecure: config.isImapServerSecure,
    );
    final imapDirectoryService = ImapDirectoryService(
      path: config.boxName,
      imapClientService: imapClientService,
      localSQLite: _localSQLite,
    );
    _imapDirectoryService = imapDirectoryService;
    if (!await _imapDirectoryService.exists()) {
      await _imapDirectoryService.create();
    }
    await Future.delayed(Duration(seconds: 3));
  }

  /// Start synchronizing data
  Future<void> start() {
    Completer<void> completer = Completer();
    (() async {
      while (true) {
        try {
          if (!_isInit) {
            await _init(_config);
            _isInit = true;
            completer.complete();
            await _imapDirectoryService.selectPath();
          }
          await OnlineSyncToLocalService(
            imapDirectoryService: _imapDirectoryService,
            localSQLite: _localSQLite,
            imapCache: _imapCache,
          ).start();
        } catch (e) {
          Logger.error(e.toString());
        }
        await Future.delayed(Duration(seconds: 5));
      }
    })();

    return completer.future;
  }
}
