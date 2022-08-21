class OnlineCacheInfoModel {
  static String tableName = 'online_cache_info';

  int uid;
  String key;
  String hash;
  String symbol;
  DateTime updatedAt;
  DateTime? deletedAt;

  OnlineCacheInfoModel({
    required this.uid,
    required this.key,
    required this.hash,
    required this.symbol,
    required this.updatedAt,
    deletedAt,
  });
}
