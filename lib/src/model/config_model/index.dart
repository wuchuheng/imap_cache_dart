import 'package:json_annotation/json_annotation.dart';

part 'index.g.dart';

@JsonSerializable()
class ConfigModel {
  static String tableName = 'config';
  final id = 1;
  final DateTime updatedAt;

  ConfigModel({required this.updatedAt});
  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    return _$ConfigModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ConfigModelToJson(this);
}
