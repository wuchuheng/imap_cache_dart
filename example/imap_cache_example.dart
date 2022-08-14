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

  /// event subscription usage.
  final setSubscribeHandle = cacheServiceInstance.beforeSetSubscribe(
    key: 'foo',
    callback: (value) async {
      print('the value have been set. key: foo; value: $value');
      value = 'hello, $value ';
      return value;
    },
  );

  ///  Trigger setting events after set the foo variables
  await cacheServiceInstance.set(key: 'foo', value: 'hello');
  final unsetSubscribeHandle = cacheServiceInstance.unsetEventSubscribe(
      key: 'foo',
      callback: ({required key}) {
        print('the value have been deleted. key: $key.');
      });

  ///  Trigger unseting events after delete the foo variables
  await cacheServiceInstance.unset(key: 'foo');

  /// Unsubscribe from events for foo key
  setSubscribeHandle.unsubscribe();
  unsetSubscribeHandle.unsubscribe();

  /// Data synchronization events
  /// Triggers an event when the online data and offline data start to synchronize.
  cacheServiceInstance
      .startSyncEvent(() => print('Triggers an event when the online data and offline data start to synchronize.'));

  /// Triggers an event when data synchronization is complete.
  cacheServiceInstance.completedSyncEvent(() => print('Triggers an event when data synchronization is complete.'));

  /// Listening to data synchronized online to offline
  final beforeOnlineModifyLocalEventHandler = cacheServiceInstance.beforeOnlineModifyLocalEvent(
      key: 'tmptmp',
      callback: ({required String onlineValue}) async {
        print(onlineValue);
        return onlineValue;
      });
}
