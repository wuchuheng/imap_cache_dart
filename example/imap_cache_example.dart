import 'package:imap_cache/imap_cache.dart';
import 'package:imap_cache/src/dto/connect_config/index.dart';
import 'package:imap_cache/src/service/imap_cache_service/index_abstarct.dart';

void main() async {
  final config = ConnectConfig(
    userName: '<email account>',
    password: '<password>',
    imapServerHost: '<IMAP host>',
    imapServerPort: 993,
    isImapServerSecure: true,
    boxName: 'snotes',
  );
  final ImapCacheServiceAbstract cacheServiceInstance = await ImapCache().connectToServer(config);

  /// set Data
  await cacheServiceInstance.set(key: 'foo', value: 'hello');

  /// print: hello
  print(await cacheServiceInstance.get(key: 'foo'));

  /// print: true
  print(await cacheServiceInstance.has(key: 'foo'));
  await cacheServiceInstance.unset(key: 'foo');

  /// print: false
  print(await cacheServiceInstance.has(key: 'foo'));

  ///  Trigger setting events after set the foo variables
  await cacheServiceInstance.set(key: 'foo', value: 'hello');
  final unsetSubscribeHandle = cacheServiceInstance.beforeSet(
      key: 'foo',
      callback: ({required String key, required String value, required String hash}) async {
        return 'new value';
      });

  ///  Trigger unseting events after delete the foo variables
  await cacheServiceInstance.unset(key: 'foo');

  /// Unsubscribe from events for foo key
  unsetSubscribeHandle.unsubscribe();
  unsetSubscribeHandle.unsubscribe();
}
