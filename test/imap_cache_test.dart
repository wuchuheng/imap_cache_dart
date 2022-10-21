import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:wuchuheng_env/wuchuheng_env.dart';
import 'package:wuchuheng_imap_cache/wuchuheng_imap_cache.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

void main() {
  Future<ImapCacheService> getClient(String dir) async {
    final config = ConnectConfig(
      isDebug: DotEnv.get('IS_DEBUG', true),
      userName: DotEnv.get('USER_NAME', ''),
      password: DotEnv.get('PASSWORD', ''),
      imapServerHost: DotEnv.get('HOST', ''),
      imapServerPort: int.parse(DotEnv.get('PORT', '')),
      isImapServerSecure: DotEnv.get('TLS', true),
      syncIntervalSeconds: 5,
      boxName: DotEnv.get('BOX_NAME', ''),
      localCacheDirectory: dir,
    );
    if (Directory(dir).existsSync()) Directory(dir).delete(recursive: true);
    Directory(dir).create(recursive: true);

    return await ImapCache().connectToServer(config);
  }

  Future<ImapCacheService> getClient1() async => await getClient('~/tmp/client1');
  Future<ImapCacheService> getClient2() async => await getClient('~/tmp/client2');

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
    test('Test event for afterSet and beforeSet.', () async {
      final String setKey = 'setKey';
      final expectValue = 'hello';
      late From expectLocalBeforeSetFrom;
      late From expectLocalAfterSetFrom;
      final client1 = await getClient1();
      client1.beforeSet(callback: ({required key, required value, required hash, required From from}) async {
        if (key == setKey) {
          expectLocalBeforeSetFrom = from;
          return expectValue;
        }
        return value;
      });
      String expectAfterValue = '';
      client1.afterSet(callback: ({required key, required value, required hash, required From from}) async {
        expectAfterValue = value;
        expectLocalAfterSetFrom = from;
      });
      await client1.set(key: key, value: value);
      await client1.set(key: setKey, value: 'tmp');
      expect(await client1.get(key: setKey), expectValue);
      expect(expectAfterValue, expectValue);
      expect(expectLocalAfterSetFrom, From.local);
      expect(expectLocalBeforeSetFrom, From.local);

      late From expectOnlineBeforeSetFrom;
      late From expectOnlineAfterSetFrom;
      final client2SetKey = 'clientkey';
      final client2SetValue = DateTime.now().toString();
      final client2 = await getClient2();
      client1.beforeSet(callback: ({required key, required value, required hash, required From from}) async {
        if (key == client2SetKey) {
          expectOnlineBeforeSetFrom = from;
        }
        return value;
      });
      client1.afterSet(callback: ({required key, required value, required hash, required From from}) async {
        if (key == client2SetKey) {
          expectOnlineAfterSetFrom = from;
        }
      });
      client2.set(key: client2SetKey, value: client2SetValue);
      await Future.delayed(Duration(seconds: 20));
      expect(expectOnlineAfterSetFrom, From.online);
      expect(expectOnlineBeforeSetFrom, From.online);
      client1.disconnect();
      client2.disconnect();
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

    test('Event test for onUpdate and onUpdated.', () async {
      final syncIntervalSeconds = 5;
      bool isUpdate = false;
      bool isCompleteUpdate = false;
      imapCache.onUpdate(() => isUpdate = true);
      imapCache.onUpdated(() => isCompleteUpdate = true);
      imapCache.setSyncInterval(syncIntervalSeconds);
      imapCache.set(key: 'testForOnUpdateEvent', value: 'testForOnUpdateEvent');
      await Future.delayed(Duration(seconds: 10));
      expect(isUpdate, true);
      expect(isCompleteUpdate, true);
    }, timeout: Timeout(Duration(seconds: 12)));

    test('Event test for onDownload and onDownloaded.', () async {
      bool isDownload = false;
      bool isDownloaded = false;
      imapCache.onDownload(() => isDownload = true);
      imapCache.onDownloaded(() => isDownloaded = true);
      final client1 = await getClient1();
      client1.set(key: 'tmp', value: DateTime.now().toString());
      await Future.delayed(Duration(seconds: 10));
      expect(isDownload, true);
      expect(isDownloaded, true);
      client1.disconnect();
    }, timeout: Timeout(Duration(seconds: 12)));

    test('setSyncInterval test', () async {
      final syncIntervalSeconds = 20;
      late int expectValue;
      imapCache.beforeSync((duration) {
        expectValue = duration.inSeconds;
      });
      imapCache.setSyncInterval(syncIntervalSeconds);
      await Future.delayed(Duration(seconds: syncIntervalSeconds * 2));
      expect(syncIntervalSeconds, expectValue);
    }, timeout: Timeout(Duration(seconds: 41)));
    test('Dispose', () async {
      const dir = '~/';
      if (Directory(dir).existsSync()) Directory(dir).delete(recursive: true);
    });
  });
}
