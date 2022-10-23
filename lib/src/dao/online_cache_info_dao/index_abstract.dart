import 'package:wuchuheng_imap_cache/src/model/online_cache_info_model/index.dart';

abstract class OnlineCacheInfoDaoAbstract {
  Future<OnlineCacheInfoModel> save(OnlineCacheInfoModel onlineCacheInfo);
  Future<OnlineCacheInfoModel?> findByKey({required String key});
  Future<List<OnlineCacheInfoModel>> fetch();
  Future<void> destroyByUid(int uid);
  Future<List<OnlineCacheInfoModel>> fetchALLByKey(String keys);
}
