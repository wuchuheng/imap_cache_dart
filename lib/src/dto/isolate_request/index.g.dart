// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IsolateRequest _$IsolateRequestFromJson(Map<String, dynamic> json) =>
    IsolateRequest(
      dateType: $enumDecode(_$DateTypeEnumMap, json['dateType']),
      data: json['data'] as String,
    );

Map<String, dynamic> _$IsolateRequestToJson(IsolateRequest instance) =>
    <String, dynamic>{
      'dateType': _$DateTypeEnumMap[instance.dateType]!,
      'data': instance.data,
    };

const _$DateTypeEnumMap = {
  DateType.CONNECT: 'CONNECT',
};
