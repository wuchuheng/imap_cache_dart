import 'package:json_annotation/json_annotation.dart';

part 'index.g.dart';

@JsonSerializable()
class IsolatePayload {
  final String key;
  final String? value;
  final String? hash;
  IsolatePayload({required this.key, this.value, this.hash});

  factory IsolatePayload.fromJson(Map<String, dynamic> json) {
    return _$IsolatePayloadFromJson(json);
  }

  Map<String, dynamic> toJson() => _$IsolatePayloadToJson(this);
}
