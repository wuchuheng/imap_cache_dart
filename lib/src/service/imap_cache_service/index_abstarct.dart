import 'package:wuchuheng_imap_cache/src/service/sync_service/sync_event.dart';

import '../../subscription/subscription_abstract.dart';
import 'cache_abstract.dart';
import 'connect_abstract.dart';

abstract class ImapCacheService implements ConnectAbstract, CacheAbstract, SubscriptionAbstract, SyncEvent {}
