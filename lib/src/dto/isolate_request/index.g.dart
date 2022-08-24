// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IsolateRequest _$IsolateRequestFromJson(Map<String, dynamic> json) =>
    IsolateRequest(
      dateType: $enumDecode(_$DateTypeEnumMap, json['dateType']),
      payload: json['payload'] as String,
    );

Map<String, dynamic> _$IsolateRequestToJson(IsolateRequest instance) =>
    <String, dynamic>{
      'dateType': _$DateTypeEnumMap[instance.dateType]!,
      'payload': instance.payload,
    };

const _$DateTypeEnumMap = {
  DateType.CONNECT: 'CONNECT',
  DateType.SET: 'SET',
  DateType.GET: 'GET',
  DateType.UNSET: 'UNSET',
};
