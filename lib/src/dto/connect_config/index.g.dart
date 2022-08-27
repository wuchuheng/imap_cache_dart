// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConnectConfig _$ConnectConfigFromJson(Map<String, dynamic> json) =>
    ConnectConfig(
      userName: json['userName'] as String,
      password: json['password'] as String,
      imapServerHost: json['imapServerHost'] as String,
      imapServerPort: json['imapServerPort'] as int,
      isImapServerSecure: json['isImapServerSecure'] as bool,
      boxName: json['boxName'] as String,
      syncIntervalSeconds: json['syncIntervalSeconds'] as int? ?? 5,
      isDebug: json['isDebug'] as bool? ?? false,
      localCacheDirectory: json['localCacheDirectory'] as String,
    );

Map<String, dynamic> _$ConnectConfigToJson(ConnectConfig instance) =>
    <String, dynamic>{
      'userName': instance.userName,
      'password': instance.password,
      'imapServerHost': instance.imapServerHost,
      'imapServerPort': instance.imapServerPort,
      'isImapServerSecure': instance.isImapServerSecure,
      'boxName': instance.boxName,
      'syncIntervalSeconds': instance.syncIntervalSeconds,
      'isDebug': instance.isDebug,
      'localCacheDirectory': instance.localCacheDirectory,
    };
