import 'package:json_annotation/json_annotation.dart';

part 'index.g.dart';

@JsonSerializable()
class ConnectConfig {
  final String userName;
  final String password;
  final String imapServerHost;
  final int imapServerPort;
  final bool isImapServerSecure;
  final String boxName;
  final int syncIntervalSeconds;
  final bool isDebug;
  String? localCacheDirectory;

  ConnectConfig({
    required this.userName,
    required this.password,
    required this.imapServerHost,
    required this.imapServerPort,
    required this.isImapServerSecure,
    required this.boxName,
    this.syncIntervalSeconds = 5,
    this.isDebug = false,
    this.localCacheDirectory,
  });

  factory ConnectConfig.fromJson(Map<String, dynamic> json) {
    return _$ConnectConfigFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ConnectConfigToJson(this);
}
