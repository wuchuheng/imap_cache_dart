import 'package:wuchuheng_imap_cache/src/model/online_cache_info_model/index.dart';

abstract class OnlineCacheInfoDaoAbstract {
  OnlineCacheInfoModel save(OnlineCacheInfoModel onlineCacheInfo);
  OnlineCacheInfoModel? findByKey({required String key});
  List<OnlineCacheInfoModel> fetch();
  void destroyByUid(int uid);
  void destroyAllData();
  List<OnlineCacheInfoModel> fetchALLByKey(String keys);
}
