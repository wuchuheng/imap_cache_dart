import 'package:wuchuheng_imap_cache/src/dto/subject_info.dart';
import 'package:wuchuheng_imap_cache/src/errors/not_found_email_error.dart';
import 'package:wuchuheng_imap_cache/src/model/cache_info_model/index.dart';
import 'package:wuchuheng_imap_cache/src/model/online_cache_info_model/index.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

import '../../../../wuchuheng_imap_cache.dart';
import '../../../dao/db.dart';
import '../../imap_cache_service/imap_cache_service.dart';
import '../../imap_directory_service/index.dart';
import 'IMAP_sync_service.dart';

class IMAPSyncServiceI implements IMAPSyncService {
  late ImapDirectoryService _imapDirectoryService;
  late LocalSQLite _localSQLite;
  late ImapCacheServiceI _imapCache;
  final void Function() onUpdate;
  final void Function() onUpdated;
  final void Function() onDownload;
  final void Function() onDownloaded;

  IMAPSyncServiceI({
    required this.onUpdate,
    required ImapDirectoryService imapDirectoryService,
    required LocalSQLite localSQLite,
    required ImapCacheServiceI imapCache,
    required this.onUpdated,
    required this.onDownload,
    required this.onDownloaded,
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
    final localData = await _localSQLite.cacheInfoDao().fetchLocal();
    if (localData.isNotEmpty) onUpdate();
    for (final item in localData) {
      await _imapDirectoryService.createFile(fileName: item.symbol, content: item.value);
      Logger.info('Local -> online; key: ${item.key}; value: ${item.value}');
      final List<OnlineCacheInfoModel> onlineCacheList =
          await _localSQLite.onlineCacheInfoDao().fetchALLByKey(item.key);
      for (final onlineItem in onlineCacheList) {
        try {
          await _imapDirectoryService.deleteFileByUid(onlineItem.uid);
        } catch (e) {
          Logger.error('failed to delete online data. key: ${onlineItem.key}; symbol: ${onlineItem.symbol}');
        }
        await _localSQLite.onlineCacheInfoDao().destroyByUid(onlineItem.uid);
      }
    }
    if (localData.isNotEmpty) onUpdated();
  }

  @override
  Future<void> onlineSyncToLocal() async {
    final List<OnlineCacheInfoModel> onlineCacheInfoList = await _localSQLite.onlineCacheInfoDao().fetch();
    if (onlineCacheInfoList.isNotEmpty) onDownload();
    for (final onlineItem in onlineCacheInfoList) {
      final localItem = await _localSQLite.cacheInfoDao().findByKey(key: onlineItem.key);
      if (localItem != null) {
        final localTime = localItem.updatedAt.microsecondsSinceEpoch;
        final onlineTime = onlineItem.updatedAt.microsecondsSinceEpoch;
        if (localTime < onlineTime) {
          try {
            await _onlineSyncToLocalProcess(onlineCacheInfoModel: onlineItem);
          } on NotFoundEmailError {
            continue;
          }
        } else if (localTime == onlineTime && localItem.uid < onlineItem.uid) {
          localItem.uid = onlineItem.uid;
          await _localSQLite.cacheInfoDao().save(localItem);
        }
      } else {
        try {
          await _onlineSyncToLocalProcess(onlineCacheInfoModel: onlineItem);
        } on NotFoundEmailError {
          continue;
        }
      }
    }
    if (onlineCacheInfoList.isNotEmpty) onDownloaded();
  }

  Future<void> _onlineSyncToLocalProcess({required OnlineCacheInfoModel onlineCacheInfoModel}) async {
    String value = '';
    try {
      value = await _imapDirectoryService.getFileByUid(onlineCacheInfoModel.uid) as String;
    } catch (e, track) {
      Logger.error(
        'Failed to fetch online data, uid: ${onlineCacheInfoModel.uid}; symbol: ${onlineCacheInfoModel.symbol}',
      );
      print(track);
      rethrow;
    }

    final cacheInfo = CacheInfoModel(
      updatedAt: onlineCacheInfoModel.updatedAt,
      symbol: onlineCacheInfoModel.symbol,
      value: value,
      key: onlineCacheInfoModel.key,
      hash: onlineCacheInfoModel.hash,
    );
    //
    if (_imapCache.keyMapUpdatedAt.containsKey(onlineCacheInfoModel.key) &&
        _imapCache.keyMapUpdatedAt[onlineCacheInfoModel.key]!.microsecondsSinceEpoch >
            onlineCacheInfoModel.updatedAt.microsecondsSinceEpoch) {
      return;
    }
    if (onlineCacheInfoModel.deletedAt != null) {
      await _imapCache.unset(key: onlineCacheInfoModel.key);
      await _localSQLite.cacheInfoDao().save(cacheInfo);
      Logger.info('Online -> local; Data synchronization; key: ${onlineCacheInfoModel.key} value: $value');
    } else {
      await _imapCache.setWithFrom(key: cacheInfo.key, value: value, from: From.online);
      final CacheInfoModel localData = (await _localSQLite.cacheInfoDao().findByKey(key: onlineCacheInfoModel.key))!;
      localData.uid = onlineCacheInfoModel.uid;
      if (cacheInfo.value == value) {
        localData.hash = onlineCacheInfoModel.hash;
        localData.updatedAt = onlineCacheInfoModel.updatedAt;
        localData.deletedAt = onlineCacheInfoModel.deletedAt;
        localData.symbol = onlineCacheInfoModel.symbol;
      }
      await _localSQLite.cacheInfoDao().save(localData);
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
      await _localSQLite.onlineCacheInfoDao().save(onlineCacheInfoModel);
    }
  }
}
