import 'package:json_annotation/json_annotation.dart';

part 'index.g.dart';

@JsonSerializable()
class IsolateResponse {
  final bool isSuccess;
  final String? data;
  final String? error;

  IsolateResponse({
    required this.isSuccess,
    this.data,
    this.error,
  });

  factory IsolateResponse.fromJson(Map<String, dynamic> json) {
    return _$IsolateResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$IsolateResponseToJson(this);
}
