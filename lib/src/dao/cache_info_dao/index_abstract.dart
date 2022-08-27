import 'package:wuchuheng_imap_cache/src/model/cache_info_model/index.dart';

abstract class CacheInfoDaoAbstract {
  void save(CacheInfoModel cacheInfo);
  CacheInfoModel? findByKey({required String key});
  void destroyByKey({required String key});
  List<CacheInfoModel> fetchLocal();
}
