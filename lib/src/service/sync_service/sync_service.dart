import 'set_sync_interval.dart';
import 'sync_event.dart';

abstract class SyncService implements SyncEvent, SetSyncInterval {
  Future<void> start();

  Future<void> stop();
}
