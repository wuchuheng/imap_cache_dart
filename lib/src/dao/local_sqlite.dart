import 'dart:io';

import 'package:sqlite3/sqlite3.dart';
import 'package:wuchuheng_imap_cache/src/dao/cache_info_dao/index.dart';
import 'package:wuchuheng_imap_cache/src/dao/online_cache_info_dao/index.dart';
import 'package:wuchuheng_imap_cache/src/model/online_cache_info_model/index.dart';

import '../model/cache_info_model/index.dart';
import 'db.dart';

class LocalSQLite {
  DB _DB;
  LocalSQLite(this._DB);
  Database? _db;
  Database getDb() {
    if (_db == null) throw Error();
    return _db!;
  }

  init({required String userName, String? localCacheDirectory}) async {
    String path = '$localCacheDirectory/localCache/$userName';
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
        "uid" INTEGER NOT NULL,
        "value" TEXT,
        "hash" TEXT,
        "symbol" TEXT,
        "updated_at" DATE,
        "deleted_at" DATE,
        PRIMARY KEY ("key", "uid")
      );
  ''');
    }
    final hasOnlineCacheInfoTable = getDb().select(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='${OnlineCacheInfoModel.tableName}'",
    );
    if (hasOnlineCacheInfoTable.isEmpty) {
      final db = getDb();
      db.execute('''
      CREATE TABLE "${OnlineCacheInfoModel.tableName}" (
        "key" TEXT NOT NULL,
        "uid" INTEGER NOT NULL,
        "hash" TEXT,
        "symbol" TEXT,
        "updated_at" DATE,
        "deleted_at" DATE,
        PRIMARY KEY ("key", "uid")
      );
  ''');
    }

    return this;
  }

  CacheInfoDao cacheInfoDao() => CacheInfoDao(getDb: () => getDb(), DB: _DB);

  OnlineCacheInfoDao onlineCacheInfoDao() => OnlineCacheInfoDao(getDb: () => getDb(), DB: _DB);
}
