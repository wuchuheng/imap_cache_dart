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
  /// Triggers an event when the online data and offline data start to synchronize.
  cacheServiceInstance.startSyncEvent(() => print(
      'Triggers an event when the online data and offline data start to synchronize.'
  ));
  /// Triggers an event when data synchronization is complete.
  cacheServiceInstance.completedSyncEvent(() => print(
      'Triggers an event when data synchronization is complete.'
  ) );
}