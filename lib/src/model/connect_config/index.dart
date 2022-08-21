class ConnectConfig {
  String userName;
  String password;
  String imapServerHost;
  int imapServerPort;
  bool isImapServerSecure;
  String boxName;
  int syncIntervalSeconds;
  bool isDebug;

  ConnectConfig({
    required this.userName,
    required this.password,
    required this.imapServerHost,
    required this.imapServerPort,
    required this.isImapServerSecure,
    required this.boxName,
    required this.syncIntervalSeconds,
    required this.isDebug,
  });
}
