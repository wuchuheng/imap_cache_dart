import 'package:json_annotation/json_annotation.dart';

part 'index.g.dart';

enum DateType {
  CONNECT,
  SET,
  GET,
  UNSET,
}

@JsonSerializable()
class IsolateRequest {
  final DateType dateType;
  final String payload;

  IsolateRequest({
    required this.dateType,
    required this.payload,
  });

  factory IsolateRequest.fromJson(Map<String, dynamic> json) {
    return _$IsolateRequestFromJson(json);
  }

  Map<String, dynamic> toJson() => _$IsolateRequestToJson(this);
}
