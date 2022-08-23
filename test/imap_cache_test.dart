import 'dart:io';

import 'package:imap_cache/imap_cache.dart';
import 'package:imap_cache/src/dto/connect_config/index.dart';
import 'package:imap_cache/src/service/imap_cache_service/index_abstarct.dart';
import 'package:test/test.dart';
import 'package:wuchuheng_env/wuchuheng_env.dart';

void main() {
  group('A group of tests', () {
    // final awesome = Awesome();

    setUp(() {
      // Additional setup goes here.
    });

    final file = '${Directory.current.path}/test/.env';
    final env = Load(file: file).env;
    test('Connect Test', () async {
      final config = ConnectConfig(
        isDebug: env['IS_DEBUG']!.toLowerCase() == 'true',
        userName: env['USER_NAME']!,
        password: env['PASSWORD']!,
        imapServerHost: env['HOST']!,
        imapServerPort: int.parse(env['PORT']!),
        isImapServerSecure: env['TLS']!.toLowerCase() == 'true',
        boxName: env['BOX_NAME']!,
        localCacheDirectory: env['LOCAL_CACHE_DIRECTORY']!,
      );
      ImapCacheServiceAbstract imapCache = await ImapCache().connectToServer(config);
      await Future.delayed(Duration(seconds: 50));
    });
  });
}
