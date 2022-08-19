import 'package:imap_cache/src/model/cache_info_model/index.dart';

abstract class CacheInfoDaoAbstract {
  void set({required String key, required String value});
  CacheInfoModel? has({required String key});
}
