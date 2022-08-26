// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IsolateRequest _$IsolateRequestFromJson(Map<String, dynamic> json) =>
    IsolateRequest(
      dateType: $enumDecode(_$DataTypeEnumMap, json['dateType']),
      payload: json['payload'] as String,
    );

Map<String, dynamic> _$IsolateRequestToJson(IsolateRequest instance) =>
    <String, dynamic>{
      'dateType': _$DataTypeEnumMap[instance.dateType]!,
      'payload': instance.payload,
    };

const _$DataTypeEnumMap = {
  DataType.CONNECT: 'CONNECT',
  DataType.SET: 'SET',
  DataType.GET: 'GET',
  DataType.UNSET: 'UNSET',
  DataType.HAS: 'HAS',
};
