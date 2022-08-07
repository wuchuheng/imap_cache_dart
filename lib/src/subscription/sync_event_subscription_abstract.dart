import 'package:imap_cache/src/subscription/subscription_abstract.dart';

abstract class SyncEventSubscriptionAbstract {
  UnsubscribeAbstract startSyncEvent(void Function() callback);

  UnsubscribeAbstract completedSyncEvent(void Function() callback);

  /// Events triggered before offline modification of offline data.
  UnsubscribeAbstract beforeOnlineModifyLocalEvent({
    required String key,
    required Future<String> Function({
    required String onlineValue,
    }) callback
  });
}
