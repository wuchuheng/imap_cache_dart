import 'package:imap_cache/src/subscription/subscription_abstract.dart';

abstract class SyncEventSubscriptionAbstract {
  UnsubscribeAbstract startSyncEvent(void Function() callback);

  UnsubscribeAbstract completedSyncEvent(void Function() callback);
}