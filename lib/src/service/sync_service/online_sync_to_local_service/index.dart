import 'package:wuchuheng_imap_cache/src/dto/subject_info.dart';
import 'package:wuchuheng_imap_cache/src/model/cache_info_model/index.dart';
import 'package:wuchuheng_imap_cache/src/model/online_cache_info_model/index.dart';
import 'package:wuchuheng_imap_cache/src/service/sync_service/online_sync_to_local_service/online_sync_to_local_service.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

import '../../../dao/local_sqlite.dart';
import '../../imap_cache_service/index.dart';
import '../../imap_directory_service/index.dart';

class OnlineSyncToLocalServiceI implements OnlineSyncToLocalService {
  late ImapDirectoryService _imapDirectoryService;
  late LocalSQLite _localSQLite;
  late ImapCacheServiceI _imapCache;

  OnlineSyncToLocalServiceI({
    required ImapDirectoryService imapDirectoryService,
    required LocalSQLite localSQLite,
    required ImapCacheServiceI imapCache,
  }) {
    _imapCache = imapCache;
    _imapDirectoryService = imapDirectoryService;
    _localSQLite = localSQLite;
  }

  @override
  Future<void> start() async {
    Logger.info('Start sync data.');
    await fetchOnlineDataToLocalDB();
    await onlineSyncToLocal();
    await localSyncToOnline();
    Logger.info('Completed data sync');
  }

  @override
  Future<void> localSyncToOnline() async {
    final localData = _localSQLite.cacheInfoDao().fetchLocal();
    for (final item in localData) {
      await _imapDirectoryService.createFile(fileName: item.symbol, content: item.value);
      Logger.info('Local -> online; key: ${item.key}; value: ${item.value}');
      final onlineCacheList = _localSQLite.onlineCacheInfoDao().fetchALLByKey(item.key);
      for (final onlineItem in onlineCacheList) {
        try {
          await _imapDirectoryService.deleteFileByUid(onlineItem.uid);
        } catch (e) {
          Logger.error('failed to delete online data. key: ${onlineItem.key}; symbol: ${onlineItem.symbol}');
        }
        _localSQLite.onlineCacheInfoDao().destroyByUid(onlineItem.uid);
      }
    }
  }

  @override
  Future<void> onlineSyncToLocal() async {
    final List<OnlineCacheInfoModel> onlineCacheInfoList = _localSQLite.onlineCacheInfoDao().fetch();
    for (final onlineItem in onlineCacheInfoList) {
      final localItem = _localSQLite.cacheInfoDao().findByKey(key: onlineItem.key);
      if (localItem != null) {
        final localTime = localItem.updatedAt.microsecondsSinceEpoch;
        final onlineTime = onlineItem.updatedAt.microsecondsSinceEpoch;
        if (localTime < onlineTime) {
          await _onlineSyncToLocalProcess(onlineCacheInfoModel: onlineItem);
        } else if (localTime == onlineTime && localItem.uid < onlineItem.uid) {
          localItem.uid = onlineItem.uid;
          _localSQLite.cacheInfoDao().save(localItem);
        }
      } else {
        await _onlineSyncToLocalProcess(onlineCacheInfoModel: onlineItem);
      }
    }
  }

  Future<void> _onlineSyncToLocalProcess({required OnlineCacheInfoModel onlineCacheInfoModel}) async {
    String value = '';
    try {
      value = await _imapDirectoryService.getFileByUid(onlineCacheInfoModel.uid) as String;
    } catch (e) {
      Logger.error(
        'Failed to fetch online data, uid: ${onlineCacheInfoModel.uid}; symbol: ${onlineCacheInfoModel.symbol}',
      );
    }

    final cacheInfo = CacheInfoModel(
      updatedAt: onlineCacheInfoModel.updatedAt,
      symbol: onlineCacheInfoModel.symbol,
      value: value,
      key: onlineCacheInfoModel.key,
      hash: onlineCacheInfoModel.hash,
    );
    if (onlineCacheInfoModel.deletedAt != null) {
      await _imapCache.unset(key: onlineCacheInfoModel.key);
      _localSQLite.cacheInfoDao().save(cacheInfo);
      Logger.info('Online -> local; Data synchronization; key: ${onlineCacheInfoModel.key} value: $value');
    } else {
      await _imapCache.set(key: cacheInfo.key, value: value);
      final CacheInfoModel localData = _localSQLite.cacheInfoDao().findByKey(key: onlineCacheInfoModel.key)!;
      localData.uid = onlineCacheInfoModel.uid;
      if (cacheInfo.value == value) {
        localData.hash = onlineCacheInfoModel.hash;
        localData.updatedAt = onlineCacheInfoModel.updatedAt;
        localData.deletedAt = onlineCacheInfoModel.deletedAt;
        localData.symbol = onlineCacheInfoModel.symbol;
      }
      _localSQLite.cacheInfoDao().save(localData);
      Logger.info(
        'Online -> local; Synchronize online and delete local data; key: ${onlineCacheInfoModel.key} value: $value',
      );
    }
  }

  /// Pull down the offline data
  @override
  Future<void> fetchOnlineDataToLocalDB() async {
    List<SubjectInfo> subjects = await _imapDirectoryService.getFiles();
    for (final subject in subjects) {
      final onlineCacheInfoModel = OnlineCacheInfoModel(
        uid: subject.uid,
        key: subject.symbol.key,
        hash: subject.symbol.hash,
        symbol: subject.symbol.toString(),
        updatedAt: subject.symbol.updatedAt,
        deletedAt: subject.symbol.deletedAt,
      );
      _localSQLite.onlineCacheInfoDao().save(onlineCacheInfoModel);
    }
  }
}
