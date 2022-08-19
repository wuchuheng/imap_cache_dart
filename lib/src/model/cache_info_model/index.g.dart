// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CacheInfoModel _$CacheInfoModelFromJson(Map<String, dynamic> json) =>
    CacheInfoModel(
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      symbol: json['symbol'] as String,
      uid: json['uid'] as int?,
      value: json['value'] as String,
      key: json['key'] as String,
      hash: json['hash'] as String,
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$CacheInfoModelToJson(CacheInfoModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'value': instance.value,
      'key': instance.key,
      'hash': instance.hash,
      'symbol': instance.symbol,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };
