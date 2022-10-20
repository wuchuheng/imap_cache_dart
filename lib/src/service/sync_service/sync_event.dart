import 'package:wuchuheng_hooks/wuchuheng_hooks.dart';

typedef BeforeSyncCallback = void Function(Duration duration);
typedef AfterSyncCallback = BeforeSyncCallback;

abstract class SyncEvent {
  Unsubscribe beforeSync(BeforeSyncCallback callback);
  Unsubscribe afterSync(AfterSyncCallback callback);

  /// Start uploading data to the server
  Unsubscribe onUpdate(void Function() callback);

  /// Start uploading data to the server
  Unsubscribe onUpdated(void Function() callback);

  /// The event to downloading data from online to the local.
  Unsubscribe onDownload(void Function() callback);

  /// The event to downloaded data from online to the local.
  Unsubscribe onDownloaded(void Function() callback);
}
