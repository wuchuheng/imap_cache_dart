import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:wuchuheng_env/wuchuheng_env.dart';
import 'package:wuchuheng_imap_cache/wuchuheng_imap_cache.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

void main() {
  group('A group of tests', () {
    late ImapCacheService imapCache;
    final key = 'hello';
    final value = 'hello';
    test('Init', () async {
      final file = '${Directory.current.path}/test/.env';
      DotEnv(path: file);
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
    test('Sync subject test', () {
      late Duration beforeDuration;
      late Duration afterDuration;
      imapCache.beforeSync((value) => beforeDuration = value);
      imapCache.afterSync((value) => afterDuration = value);
      Timer(Duration(seconds: 50), () {
        expect(beforeDuration != null, isTrue);
        expect(afterDuration != null, isTrue);
      });
    });
    test('SubjectLog test', () async {
      late LoggerItem loggerItem;
      imapCache.subscribeLog((value) => loggerItem = value);
      await imapCache.set(key: 'hello', value: 'hello');
      expect(loggerItem != null, isTrue);
    });
    test('SET afterSet beforeSet Test', () async {
      final String setKey = 'setKey';
      final expectValue = 'hello';
      imapCache.beforeSet(callback: ({required key, required value, required hash}) async {
        if (key == setKey) {
          return expectValue;
        }
        return value;
      });
      String expectAfterValue = '';
      imapCache.afterSet(callback: ({required key, required value, required hash}) async {
        expectAfterValue = value;
      });
      await imapCache.set(key: key, value: value);
      await imapCache.set(key: setKey, value: 'tmp');
      expect(await imapCache.get(key: setKey), expectValue);
      expect(expectAfterValue, expectValue);
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
    test('Unset and beforeUnset afterUnset Test', () async {
      bool callback1 = false;
      bool callback2 = false;
      imapCache.beforeUnset(callback: ({required String key}) async {
        callback1 = true;
        return true;
      });
      imapCache.beforeUnset(callback: ({required String key}) async {
        callback2 = true;
        return true;
      });
      String afterUnsetKey = '';
      imapCache.afterUnset(callback: ({required key}) async {
        afterUnsetKey = key;
      });
      await imapCache.unset(key: key);
      expect(await imapCache.has(key: key), isNull);
      expect(callback1, isTrue);
      expect(callback2, isTrue);
      expect(afterUnsetKey, key);
    }, timeout: Timeout(Duration(seconds: 60)));

    test('Duration', () async {
      await Future.delayed(Duration(seconds: 60));
    });
  });
}
