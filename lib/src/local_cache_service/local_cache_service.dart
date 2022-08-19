import 'dart:async';
import 'dart:io';

import 'package:imap_cache/src/cache_common_config.dart';
import 'package:imap_cache/src/dao/local_sqlite.dart';
import 'package:imap_cache/src/errors/key_not_found_error.dart';
import 'package:imap_cache/src/local_cache_service/local_cache_register_service.dart';
import 'package:imap_cache/src/utils/logger.dart';
import 'package:path_provider/path_provider.dart';

import '../cache_io_abstract.dart';
import '../cache_service_abstract.dart';

class LocalCacheService implements ImapServiceAbstract {
  late LocalSQLite _localSQLite;

  init({required String userName}) async {
    _localSQLite = await LocalSQLite().init(userName: userName);
    return this;
  }

  Future<String> get _path async {
    final directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}/cache/${CacheCommonConfig.userName}/data';
    if (!await Directory(path).exists()) {
      await Directory(path).create(recursive: true);
    }
    return path;
  }

  @override
  Future<String> get({required String key}) async {
    if (!await has(key: key)) throw KeyNotFoundError();
    String path = await _path;
    String filePath = '$path/$key.json';

    return File(filePath).readAsStringSync();
  }

  @override
  Future<bool> has({required String key}) async => _localSQLite.cacheInfoDao().has(key: key) != null;

  @override
  Future<void> set({required String key, required String value}) async {
    Logger.info('Start setting up local cache. key: $key value: $value');
    _localSQLite.cacheInfoDao().set(key: key, value: value);
    Logger.info('Complete local cache settings. key $key value: $value');
  }

  @override
  Future<void> unset({required String key}) async {
    if (!await has(key: key)) {
      Logger.error('Not Found key: $key');
      throw KeyNotFoundError();
    }
    RegisterInfo registerInfo = await LocalCacheRegisterService().getRegister();
    registerInfo.data[key]!.deletedAt = DateTime.now().toString();
    await LocalCacheRegisterService().setRegister(data: registerInfo);
  }
}
