import 'set_sync_interval.dart';
import 'sync_event.dart';

abstract class SyncService implements SyncEvent, SetSyncInterval {
  /// Start syncing tasks.
  Future<void> start();

  /// Stop syncing tasks.
  Future<void> stop();

  /// Refreshing synchronization tasks.
  /// Works when the sync task is blocking.
  void refresh();
}
