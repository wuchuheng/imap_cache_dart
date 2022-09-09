import 'package:wuchuheng_hooks/wuchuheng_hooks.dart';

typedef BeforeSyncCallback = void Function(Duration duration);
typedef AfterSyncCallback = BeforeSyncCallback;

abstract class SyncEvent {
  Unsubscribe beforeSync(BeforeSyncCallback callback);
  Unsubscribe afterSync(AfterSyncCallback callback);
}
