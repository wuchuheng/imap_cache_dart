import 'package:json_annotation/json_annotation.dart';

part 'index.g.dart';

@JsonSerializable()
class SetData {
  final String key;
  final String value;

  SetData({required this.key, required this.value});

  factory SetData.fromJson(Map<String, dynamic> json) {
    return _$SetDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SetDataToJson(this);
}
