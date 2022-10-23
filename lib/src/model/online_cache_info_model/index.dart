import 'package:drift/drift.dart';

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

class OnlineCacheInfo extends Table {
  TextColumn get key => text()();
  IntColumn get uid => integer()();
  TextColumn get hash => text()();
  TextColumn get symbol => text()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}
