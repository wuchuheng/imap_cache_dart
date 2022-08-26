import 'dart:io';

import 'package:imap_cache/imap_cache.dart';
import 'package:imap_cache/src/dto/connect_config/index.dart';
import 'package:imap_cache/src/service/imap_cache_service/index_abstarct.dart';
import 'package:test/test.dart';
import 'package:wuchuheng_env/wuchuheng_env.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

void main() {
  group('A group of tests', () {
    late ImapCacheServiceAbstract imapCache;
    final key = 'hello';
    final value = 'hello';
    test('Init', () async {
      final file = '${Directory.current.path}/test/.env';
      DotEnv(file: file);
      final directory = DotEnv.get('LOCAL_CACHE_DIRECTORY', '');
      final path = '$directory/localCache';
      if (await Directory(path).exists()) {
        await Directory(path).delete(recursive: true);
        Logger.info('the directory $path has been deleted');
      }
      final config = ConnectConfig(
        isDebug: DotEnv.get('IS_DEBUG', true),
        userName: DotEnv.get('USER_NAME', ''),
        password: DotEnv.get('PASSWORD', ''),
        imapServerHost: DotEnv.get('HOST', ''),
        imapServerPort: int.parse(DotEnv.get('PORT', '')),
        isImapServerSecure: DotEnv.get('TLS', true),
        boxName: DotEnv.get('BOX_NAME', ''),
        localCacheDirectory: DotEnv.get('LOCAL_CACHE_DIRECTORY', ''),
      );
      imapCache = await ImapCache().connectToServer(config);
    });
    test('SET Test', () async {
      await imapCache.set(key: key, value: value);
    });
    test('GET Test', () async {
      final result = await imapCache.get(key: key);
      expect(result, value);
    });
    test('Has Test', () async {
      expect(await imapCache.has(key: key), value);
      String? result = await imapCache.has(key: 'noneKey');
      expect(result, isNull);
    });
    test('Unset Test', () async {
      await imapCache.unset(key: key);
      expect(await imapCache.has(key: key), isNull);
    });
    test('Duration', () async {
      await Future.delayed(Duration(seconds: 5));
    });
  });
}
