import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart';
import 'package:wuchuheng_imap_cache/src/model/online_cache_info_model/index.dart';

import '../model/cache_info_model/index.dart';
import 'cache_info_dao/index.dart';
import 'online_cache_info_dao/index.dart';

part 'db.g.dart';

@DriftDatabase(tables: [CacheInfo, OnlineCacheInfo])
class DB extends _$DB {
  DB({required bool logStatements, required String DBStoreDir}) : super(_openConnection(DBStoreDir, logStatements));

  @override
  int get schemaVersion => 1;

  Future<List<CacheInfoData>> get allTodoEntries => select(cacheInfo).get();
}

LazyDatabase _openConnection(String DBStoreDir, bool logStatements) {
  return LazyDatabase(() async {
    final file = File(join(DBStoreDir, 'drift_db.sqlite'));
    return NativeDatabase(file, logStatements: logStatements);
  });
}

class LocalSQLite {
  DB _DB;
  LocalSQLite(this._DB);

  CacheInfoDao cacheInfoDao() => CacheInfoDao(DB: _DB);

  OnlineCacheInfoDao onlineCacheInfoDao() => OnlineCacheInfoDao(DB: _DB);
}
