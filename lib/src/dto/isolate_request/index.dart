import 'package:json_annotation/json_annotation.dart';

part 'index.g.dart';

enum DateType { CONNECT }

@JsonSerializable()
class IsolateRequest {
  final DateType dateType;
  final String data;

  IsolateRequest({
    required this.dateType,
    required this.data,
  });

  factory IsolateRequest.fromJson(Map<String, dynamic> json) {
    return _$IsolateRequestFromJson(json);
  }

  Map<String, dynamic> toJson() => _$IsolateRequestToJson(this);
}
