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