import 'package:json_annotation/json_annotation.dart';

part 'index.g.dart';

enum DataType {
  CONNECT,
  SET,
  GET,
  UNSET,
  HAS,
}

@JsonSerializable()
class IsolateRequest {
  final DataType dateType;
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
