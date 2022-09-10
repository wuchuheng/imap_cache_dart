import 'sync_event.dart';

abstract class SetSyncInterval {
  Future<void> setSyncInterval(int second);
}
