import 'package:json_annotation/json_annotation.dart';

part 'index.g.dart';

@JsonSerializable()
class CacheInfoModel {
  static String tableName = 'cache_info';
  int? uid;
  String value;
  String key;
  String hash;
  String symbol;
  DateTime updatedAt;
  DateTime? deletedAt;

  CacheInfoModel(
      {required this.updatedAt,
      required this.symbol,
      required this.uid,
      required this.value,
      required this.key,
      required this.hash,
      this.deletedAt});
  factory CacheInfoModel.fromJson(Map<String, dynamic> json) {
    return _$CacheInfoModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CacheInfoModelToJson(this);
}
