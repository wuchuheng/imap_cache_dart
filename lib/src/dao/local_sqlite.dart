import 'dart:io';

import 'package:imap_cache/src/dao/cache_info_dao/index.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../model/cache_info_model/index.dart';
import '../model/config_model/index.dart';

class LocalSQLite {
  Database? _db;
  Database getDb() {
    if (_db == null) throw Error();
    return _db!;
  }

  init({required String userName}) async {
    final directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}/localCache/$userName';
    final file = '$path/sqlite3.so';
    if (!await Directory(path).exists()) await Directory(path).create(recursive: true);
    _db = sqlite3.open(file);
    final hasCacheInfoTable = getDb().select(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='${CacheInfoModel.tableName}'",
    );
    if (hasCacheInfoTable.isEmpty) {
      final db = getDb();
      db.execute('''
      CREATE TABLE "${CacheInfoModel.tableName}" (
        "key" TEXT NOT NULL,
        "uid" INTEGER,
        "value" TEXT,
        "hash" TEXT,
        "symbol" TEXT,
        "updated_at" DATE,
        "deleted_at" DATE,
        PRIMARY KEY ("key")
      );
  ''');
    }
    final hasConfigTable = getDb().select(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='${ConfigModel.tableName}'",
    );
    if (hasConfigTable.isEmpty) {
      final db = getDb();
      db.execute('''
      CREATE TABLE "${ConfigModel.tableName}" (
        "id" INTEGER NOT NULL,
        "updated_at" DATE,
        PRIMARY KEY ("id")
      );
  ''');
    }

    return this;
  }

  CacheInfoDao cacheInfoDao() => CacheInfoDao(db: getDb());
}
