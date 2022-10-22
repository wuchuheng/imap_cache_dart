// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// **************************************************************************
// DriftDatabaseGenerator
// **************************************************************************

// ignore_for_file: type=lint
class CacheInfoData extends DataClass implements Insertable<CacheInfoData> {
  final String key;
  final int uid;
  final String? value;
  final String? hash;
  final String? symbol;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const CacheInfoData(
      {required this.key,
      required this.uid,
      this.value,
      this.hash,
      this.symbol,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['uid'] = Variable<int>(uid);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    if (!nullToAbsent || hash != null) {
      map['hash'] = Variable<String>(hash);
    }
    if (!nullToAbsent || symbol != null) {
      map['symbol'] = Variable<String>(symbol);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  CacheInfoCompanion toCompanion(bool nullToAbsent) {
    return CacheInfoCompanion(
      key: Value(key),
      uid: Value(uid),
      value:
          value == null && nullToAbsent ? const Value.absent() : Value(value),
      hash: hash == null && nullToAbsent ? const Value.absent() : Value(hash),
      symbol:
          symbol == null && nullToAbsent ? const Value.absent() : Value(symbol),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory CacheInfoData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheInfoData(
      key: serializer.fromJson<String>(json['key']),
      uid: serializer.fromJson<int>(json['uid']),
      value: serializer.fromJson<String?>(json['value']),
      hash: serializer.fromJson<String?>(json['hash']),
      symbol: serializer.fromJson<String?>(json['symbol']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'uid': serializer.toJson<int>(uid),
      'value': serializer.toJson<String?>(value),
      'hash': serializer.toJson<String?>(hash),
      'symbol': serializer.toJson<String?>(symbol),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  CacheInfoData copyWith(
          {String? key,
          int? uid,
          Value<String?> value = const Value.absent(),
          Value<String?> hash = const Value.absent(),
          Value<String?> symbol = const Value.absent(),
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      CacheInfoData(
        key: key ?? this.key,
        uid: uid ?? this.uid,
        value: value.present ? value.value : this.value,
        hash: hash.present ? hash.value : this.hash,
        symbol: symbol.present ? symbol.value : this.symbol,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  @override
  String toString() {
    return (StringBuffer('CacheInfoData(')
          ..write('key: $key, ')
          ..write('uid: $uid, ')
          ..write('value: $value, ')
          ..write('hash: $hash, ')
          ..write('symbol: $symbol, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(key, uid, value, hash, symbol, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheInfoData &&
          other.key == this.key &&
          other.uid == this.uid &&
          other.value == this.value &&
          other.hash == this.hash &&
          other.symbol == this.symbol &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class CacheInfoCompanion extends UpdateCompanion<CacheInfoData> {
  final Value<String> key;
  final Value<int> uid;
  final Value<String?> value;
  final Value<String?> hash;
  final Value<String?> symbol;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const CacheInfoCompanion({
    this.key = const Value.absent(),
    this.uid = const Value.absent(),
    this.value = const Value.absent(),
    this.hash = const Value.absent(),
    this.symbol = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  CacheInfoCompanion.insert({
    required String key,
    required int uid,
    this.value = const Value.absent(),
    this.hash = const Value.absent(),
    this.symbol = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
  })  : key = Value(key),
        uid = Value(uid),
        updatedAt = Value(updatedAt);
  static Insertable<CacheInfoData> custom({
    Expression<String>? key,
    Expression<int>? uid,
    Expression<String>? value,
    Expression<String>? hash,
    Expression<String>? symbol,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (uid != null) 'uid': uid,
      if (value != null) 'value': value,
      if (hash != null) 'hash': hash,
      if (symbol != null) 'symbol': symbol,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  CacheInfoCompanion copyWith(
      {Value<String>? key,
      Value<int>? uid,
      Value<String?>? value,
      Value<String?>? hash,
      Value<String?>? symbol,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt}) {
    return CacheInfoCompanion(
      key: key ?? this.key,
      uid: uid ?? this.uid,
      value: value ?? this.value,
      hash: hash ?? this.hash,
      symbol: symbol ?? this.symbol,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (uid.present) {
      map['uid'] = Variable<int>(uid.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheInfoCompanion(')
          ..write('key: $key, ')
          ..write('uid: $uid, ')
          ..write('value: $value, ')
          ..write('hash: $hash, ')
          ..write('symbol: $symbol, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $CacheInfoTable extends CacheInfo
    with TableInfo<$CacheInfoTable, CacheInfoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheInfoTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<int> uid = GeneratedColumn<int>(
      'uid', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  final VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  final VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
      'hash', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  final VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  final VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  final VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [key, uid, value, hash, symbol, updatedAt, deletedAt];
  @override
  String get aliasedName => _alias ?? 'cache_info';
  @override
  String get actualTableName => 'cache_info';
  @override
  VerificationContext validateIntegrity(Insertable<CacheInfoData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
    if (data.containsKey('hash')) {
      context.handle(
          _hashMeta, hash.isAcceptableOrUnknown(data['hash']!, _hashMeta));
    }
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  CacheInfoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheInfoData(
      key: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      uid: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}uid'])!,
      value: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}value']),
      hash: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}hash']),
      symbol: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}symbol']),
      updatedAt: attachedDatabase.options.types
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.options.types
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $CacheInfoTable createAlias(String alias) {
    return $CacheInfoTable(attachedDatabase, alias);
  }
}

abstract class _$MyDatabase extends GeneratedDatabase {
  _$MyDatabase(QueryExecutor e) : super(e);
  late final $CacheInfoTable cacheInfo = $CacheInfoTable(this);
  @override
  Iterable<TableInfo<Table, dynamic>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [cacheInfo];
}
