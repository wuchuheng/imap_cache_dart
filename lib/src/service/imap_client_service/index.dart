import 'dart:async';

import 'package:enough_mail/src/imap/imap_client.dart';
import 'package:wuchuheng_imap_cache/src/service/imap_client_service/imap_client_service_abstract.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

class ImapClientService implements ImapClientServiceAbstract {
  final String userName;
  final String password;
  final String imapServerHost;
  final int imapServerPort;
  final bool isImapServerSecure;

  ImapClientService({
    required this.userName,
    required this.password,
    required this.imapServerHost,
    required this.imapServerPort,
    required this.isImapServerSecure,
  });

  ImapClient? _client;

  @override
  Future<ImapClient> getClient() async {
    if (_client != null && _client!.isConnected) return _client!;
    final client = ImapClient(isLogEnabled: false);
    try {
      await client.connectToServer(
        imapServerHost,
        imapServerPort,
        isSecure: isImapServerSecure,
        timeout: const Duration(seconds: 30),
      );
      await client.login(userName, password);
    } catch (e) {
      Logger.error(e.toString());
      rethrow;
    }
    _client = client;

    return _client!;
  }
}
