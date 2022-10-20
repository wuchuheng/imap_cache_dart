abstract class IMAPSyncService {
  Future<void> start();

  Future<void> localSyncToOnline();

  Future<void> onlineSyncToLocal();

  /// Pull down the offline data
  Future<void> fetchOnlineDataToLocalDB();
}
