class CacheInfoModel {
  static String tableName = 'cache_info';
  int uid;
  String value;
  String key;
  String hash;
  String symbol;
  DateTime updatedAt;
  DateTime? deletedAt;

  CacheInfoModel(
      {required this.updatedAt,
      required this.symbol,
      this.uid = 0,
      required this.value,
      required this.key,
      required this.hash,
      this.deletedAt});
}
