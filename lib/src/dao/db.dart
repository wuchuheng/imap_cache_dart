import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart';

import '../model/cache_info_model/index.dart';

part 'db.g.dart';

@DriftDatabase(tables: [CacheInfo])
class DB extends _$MyDatabase {
  DB({required String DBStoreDir}) : super(_openConnection(DBStoreDir));

  @override
  int get schemaVersion => 1;

  Future<List<CacheInfoData>> get allTodoEntries => select(cacheInfo).get();
}

LazyDatabase _openConnection(String DBStoreDir) {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    final file = File(join(DBStoreDir, 'drift_db.sqlite'));
    return NativeDatabase(file);
  });
}
