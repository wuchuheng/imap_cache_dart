`imap_cache` is a data-driven caching library based on the `IMAP` protocol.

## Features

* Data Cache
* Timed synchronization
* Related event subscriptions

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

to `/example` folder. 

```dart
import 'package:imap_cache/imap_cache.dart';

void main() async {
  final ImapCache cacheServiceInstance = await ImapCache().connectToServer(
    userName: 'account@email.com',
    password: 'email password',
    imapServerHost: 'imap host',
    imapServerPort: 993,
    isImapServerSecure: true,
    boxName: 'snotes',
  );
  // set Data
  await cacheServiceInstance.set( key: 'foo', value: 'hello' );
  // print: hello
  print( await cacheServiceInstance.get(key: 'foo'));
  // print: true
  print(await cacheServiceInstance.has(key: 'foo'));
  await cacheServiceInstance.unset(key: 'foo');
  // print: false
  print(await cacheServiceInstance.has(key: 'foo'));
}
```

## Contributing

You can contribute in one of three ways:

1. File bug reports using the [issue tracker](https://github.com/wuchuheng/imap_cache_dart/issues).
2. Answer questions or fix bugs on the [issue tracker](https://github.com/wuchuheng/imap_cache_dart/issues).
3. Contribute new features or update the wiki.

## License

MIT
