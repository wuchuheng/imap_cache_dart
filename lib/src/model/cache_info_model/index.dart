import 'package:drift/drift.dart';

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

class CacheInfo extends Table {
  TextColumn get key => text()();
  IntColumn get uid => integer()();
  TextColumn get value => text().nullable()();
  TextColumn get hash => text().nullable()();
  TextColumn get symbol => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}
