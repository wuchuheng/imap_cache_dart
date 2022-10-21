import 'package:json_annotation/json_annotation.dart';

import '../../../wuchuheng_imap_cache.dart';

part 'index.g.dart';

@JsonSerializable()
class CallbackData {
  String key;
  String value;
  String hash;
  From from;

  CallbackData({required this.key, required this.value, required this.hash, required this.from});

  factory CallbackData.fromJson(Map<String, dynamic> json) {
    return _$CallbackDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CallbackDataToJson(this);
}
