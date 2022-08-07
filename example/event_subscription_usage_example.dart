import 'package:imap_cache/imap_cache.dart';

void mail() async {
  final ImapCache cacheServiceInstance = await ImapCache().connectToServer(
    userName: 'account@email.com',
    password: 'email password',
    imapServerHost: 'imap host',
    imapServerPort: 993,
    isImapServerSecure: true,
    boxName: 'snotes',
  );
  final setSubscribeHandle = cacheServiceInstance.setEventSubscribe(key: 'foo', callback: (value) {
    print('the value have been set. key: foo; value: $value');
  });
  //  Trigger setting events after set the foo variables
  await cacheServiceInstance.set( key: 'foo', value: 'hello' );
  final unsetSubscribeHandle = cacheServiceInstance.unsetEventSubscribe(key: 'foo', callback: ({required key}) {
    print('the value have been deleted. key: $key.');
  });
  //  Trigger unseting events after delete the foo variables
  await cacheServiceInstance.unset( key: 'foo');
  // Unsubscribe from events for foo key
  setSubscribeHandle.unsubscribe();
  unsetSubscribeHandle.unsubscribe();
}