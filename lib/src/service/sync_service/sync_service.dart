import 'sync_event.dart';

abstract class SyncService extends SyncEvent {
  Future<void> start();

  Future<void> stop();
}
