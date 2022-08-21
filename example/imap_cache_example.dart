import 'package:imap_cache/imap_cache.dart';

void main() async {
  final ImapCache cacheServiceInstance = await ImapCache().connectToServer(
    userName: 'my email account',
    password: 'password',
    imapServerHost: 'imap host',
    imapServerPort: 993,
    isImapServerSecure: true,
    boxName: 'snotes',
  );

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
