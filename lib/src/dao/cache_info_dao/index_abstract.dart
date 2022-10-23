import 'package:wuchuheng_imap_cache/src/model/cache_info_model/index.dart';

abstract class CacheInfoDaoAbstract {
  Future<void> save(CacheInfoModel cacheInfo);
  Future<CacheInfoModel?> findByKey({required String key});
  Future<CacheInfoModel?> findByKeyWithoutSoftDelete({required String key});
  Future<List<CacheInfoModel>> fetchLocal();
}
