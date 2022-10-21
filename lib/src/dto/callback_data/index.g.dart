// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CallbackData _$CallbackDataFromJson(Map<String, dynamic> json) => CallbackData(
      key: json['key'] as String,
      value: json['value'] as String,
      hash: json['hash'] as String,
      from: $enumDecode(_$FromEnumMap, json['from']),
    );

Map<String, dynamic> _$CallbackDataToJson(CallbackData instance) =>
    <String, dynamic>{
      'key': instance.key,
      'value': instance.value,
      'hash': instance.hash,
      'from': _$FromEnumMap[instance.from]!,
    };

const _$FromEnumMap = {
  From.local: 'local',
  From.online: 'online',
};
