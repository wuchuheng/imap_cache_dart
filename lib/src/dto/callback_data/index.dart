import 'package:json_annotation/json_annotation.dart';

part 'index.g.dart';

@JsonSerializable()
class CallbackData {
  String key;
  String value;
  String hash;

  CallbackData({required this.key, required this.value, required this.hash});

  factory CallbackData.fromJson(Map<String, dynamic> json) {
    return _$CallbackDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CallbackDataToJson(this);
}
