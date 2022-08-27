`wuchuheng_imap_cache` is a data-driven caching library based on the `IMAP` protocol.

## Features

* Data Cache
* Timed synchronization
* Related event subscriptions

## Getting started

Depend on it
Run this command:

With Dart:

``` bash 
$ dart pub add wuchuheng_imap_cache
```
With Flutter:

``` bash 
$ flutter pub add wuchuheng_imap_cache
```

This will add a line like this to your package's pubspec.yaml (and run an implicit dart pub get):

``` yaml 
dependencies:
  wuchuheng_imap_cache: ^0.0.13
```

Alternatively, your editor might support dart pub get or flutter pub get. Check the docs for your editor to learn more.

Import it
Now in your Dart code, you can use:

import ` 'package:wuchuheng_imap_cache/wuchuheng_imap_cache.dart'`;

## Usage

```dart
import 'package:wuchuheng_imap_cache/index.dart';

void main() async {
  final ImapCache cacheServiceInstance = await ImapCache().connectToServer(
    userName: '<email account>',
    password: '<password>',
    imapServerHost: '<imap host>',
    imapServerPort: 993, // host port 
    isImapServerSecure: true, // tls
    boxName: 'snotes', // box name
  );
  /// set Data
  await cacheServiceInstance.set( key: 'foo', value: 'hello' );
  /// print: hello
  print( await cacheServiceInstance.get(key: 'foo'));
  /// print: true
  print(await cacheServiceInstance.has(key: 'foo'));
  await cacheServiceInstance.unset(key: 'foo');
  /// print: false
  print(await cacheServiceInstance.has(key: 'foo'));

  /// event subscription usage.
  final setSubscribeHandle = cacheServiceInstance.setEventSubscribe(key: 'foo', callback: (value) {
    print('the value have been set. key: foo; value: $value');
  });
  ///  Trigger setting events after set the foo variables
  await cacheServiceInstance.set( key: 'foo', value: 'hello' );
  final unsetSubscribeHandle = cacheServiceInstance.unsetEventSubscribe(key: 'foo', callback: ({required key}) {
    print('the value have been deleted. key: $key.');
  });
  ///  Trigger unseting events after delete the foo variables
  await cacheServiceInstance.unset( key: 'foo');
  /// Unsubscribe from events for foo key
  setSubscribeHandle.unsubscribe();
  unsetSubscribeHandle.unsubscribe();

  /// Data synchronization events
  /// Triggers an event when the online data and offline data start to synchronize.
  cacheServiceInstance.startSyncEvent(() => print(
      'Triggers an event when the online data and offline data start to synchronize.'
  ));
  /// Triggers an event when data synchronization is complete.
  cacheServiceInstance.completedSyncEvent(() => print(
      'Triggers an event when data synchronization is complete.'
  ) );
  /// Listening to data synchronized online to offline
  final beforeOnlineModifyLocalEventHandler = cacheServiceInstance.beforeOnlineModifyLocalEvent(key: 'tmptmp', callback: ({required String onlineValue}) async{
    print(onlineValue);
    return onlineValue;
  });
}
```

## Contributing

You can contribute in one of three ways:

1. File bug reports using the [issue tracker](https://github.com/wuchuheng/wuchuheng_imap_cache_dart/issues).
2. Answer questions or fix bugs on the [issue tracker](https://github.com/wuchuheng/wuchuheng_imap_cache_dart/issues).
3. Contribute new features or update the wiki.

## License

MIT
