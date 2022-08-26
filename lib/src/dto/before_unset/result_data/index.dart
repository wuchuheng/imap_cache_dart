import 'package:json_annotation/json_annotation.dart';

part 'index.g.dart';

@JsonSerializable()
class ResultData {
  final bool result;

  ResultData({required this.result});

  factory ResultData.fromJson(Map<String, dynamic> json) {
    return _$ResultDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ResultDataToJson(this);
}
