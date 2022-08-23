// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IsolateResponse _$IsolateResponseFromJson(Map<String, dynamic> json) =>
    IsolateResponse(
      isSuccess: json['isSuccess'] as bool,
      data: json['data'] as String?,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$IsolateResponseToJson(IsolateResponse instance) =>
    <String, dynamic>{
      'isSuccess': instance.isSuccess,
      'data': instance.data,
      'error': instance.error,
    };
