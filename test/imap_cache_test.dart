import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:wuchuheng_env/wuchuheng_env.dart';
import 'package:wuchuheng_imap_cache/wuchuheng_imap_cache.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

void main() {
  const testRuntimeDir = 'tmp';
  Future<ImapCacheService> getClient(String dir) async {
    final file = '${Directory.current.path}/test/.env';
    DotEnv(path: file);
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

  Future<ImapCacheService> getClient1() => getClient('$testRuntimeDir/client1');
  Future<ImapCacheService> getClient2() => getClient('$testRuntimeDir/client2');
  Future<ImapCacheService> getClientForSyncTest() => getClient('$testRuntimeDir/clientForSyncTest');
  Future<ImapCacheService> getClientForLog() => getClient('$testRuntimeDir/clientForLogTest');
  Future<ImapCacheService> getClientForGetTest() => getClient('$testRuntimeDir/clientForGetTest');
  Future<ImapCacheService> getClientForHasTest() => getClient('$testRuntimeDir/clientForHasTest');
  Future<ImapCacheService> getClientForUnsetTest() => getClient('$testRuntimeDir/clientForUnsetTest');
  Future<ImapCacheService> getClientForUpdateTest() => getClient('$testRuntimeDir/clientForUpdateTest');
  Future<ImapCacheService> getClientForDownloadTest() => getClient('$testRuntimeDir/clientForDownloadTest');
  Future<ImapCacheService> getClientForSyncIntervalTest() => getClient('$testRuntimeDir/clientForSyncIntervalTest');

  group('A group of tests', () {
    final key = 'hello';
    final value = 'hello';

    test('Sync event test', () async {
      late Duration beforeDuration;
      late Duration afterDuration;
      ImapCacheService client = await getClientForSyncTest();
      client.beforeSync((value) => beforeDuration = value);
      client.afterSync((value) => afterDuration = value);
      await client.set(key: 'SyncEventTest', value: DateTime.now().toString());
      await Future.delayed(Duration(seconds: 10));
      expect(beforeDuration != null, isTrue);
      expect(afterDuration != null, isTrue);
      client.disconnect();
    });
    test('Log test', () async {
      late LoggerItem loggerItem;
      final ImapCacheService client = await getClientForLog();
      client.subscribeLog((value) => loggerItem = value);
      await client.set(key: 'hello', value: 'hello');
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
      final ImapCacheService client = await getClientForGetTest();
      await client.set(key: key, value: value);
      final result = await client.get(key: key);
      expect(result, value);
      client.disconnect();
    });

    test('Has Test', () async {
      final ImapCacheService client = await getClientForHasTest();
      await client.set(key: key, value: value);
      expect(await client.has(key: key), value);
      String? result = await client.has(key: 'noneKey');
      expect(result, isNull);
      client.disconnect();
    });
    test('Unset and beforeUnset afterUnset Test', () async {
      bool callback1 = false;
      bool callback2 = false;
      final ImapCacheService client = await getClientForUnsetTest();
      client.beforeUnset(callback: ({required String key}) async {
        callback1 = true;
        return true;
      });
      client.beforeUnset(callback: ({required String key}) async {
        callback2 = true;
        return true;
      });
      String afterUnsetKey = '';
      client.afterUnset(callback: ({required key}) async {
        afterUnsetKey = key;
      });
      await client.unset(key: key);
      expect(await client.has(key: key), isNull);
      expect(callback1, isTrue);
      expect(callback2, isTrue);
      expect(afterUnsetKey, key);
    }, timeout: Timeout(Duration(seconds: 60)));

    test('Event test for onUpdate and onUpdated.', () async {
      final syncIntervalSeconds = 5;
      bool isUpdate = false;
      bool isCompleteUpdate = false;
      final ImapCacheService client = await getClientForUpdateTest();
      client.onUpdate(() => isUpdate = true);
      client.onUpdated(() => isCompleteUpdate = true);
      client.setSyncInterval(syncIntervalSeconds);
      await client.set(key: 'testForOnUpdateEvent', value: 'testForOnUpdateEvent');
      await Future.delayed(Duration(seconds: 10));
      expect(isUpdate, true);
      expect(isCompleteUpdate, true);
    }, timeout: Timeout(Duration(seconds: 12)));

    test('setSyncInterval test', () async {
      final syncIntervalSeconds = 20;
      late int expectValue;
      final ImapCacheService client = await getClientForSyncIntervalTest();
      client.beforeSync((duration) {
        expectValue = duration.inSeconds;
      });
      client.setSyncInterval(syncIntervalSeconds);
      await Future.delayed(Duration(seconds: syncIntervalSeconds * 2));
      expect(syncIntervalSeconds, expectValue);
    }, timeout: Timeout(Duration(seconds: 41)));
  });

  group('A group of tests for download events', () {
    const downloadTestSeconds = 10;
    test('Init', () async {
      final client1 = await getClient1();
      await client1.set(key: 'tmp', value: DateTime.now().toString());
      await Future.delayed(Duration(seconds: 10));
      client1.disconnect();
    });

    test('Event test for onDownload and onDownloaded.', () async {
      bool isDownload = false;
      bool isDownloaded = false;
      final ImapCacheService client = await getClientForDownloadTest();
      client.onDownload(() {
        isDownload = true;
      });
      client.onDownloaded(() {
        isDownloaded = true;
      });
      await Future.delayed(Duration(seconds: downloadTestSeconds));
      expect(isDownload, true);
      expect(isDownloaded, true);
      client.disconnect();
    }, timeout: Timeout(Duration(seconds: downloadTestSeconds + 1)));
  });
}
