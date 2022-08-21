import 'package:enough_mail/enough_mail.dart';

abstract class ImapClientServiceAbstract {
  Future<ImapClient> getClient();
}
