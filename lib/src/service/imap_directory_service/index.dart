import 'package:enough_mail/enough_mail.dart';
import 'package:wuchuheng_imap_cache/src/dto/subject_info.dart';
import 'package:wuchuheng_imap_cache/src/errors/not_found_email_error.dart';
import 'package:wuchuheng_imap_cache/src/model/cache_info_model/index.dart';
import 'package:wuchuheng_imap_cache/src/service/imap_client_service/index.dart';
import 'package:wuchuheng_imap_cache/src/service/imap_directory_service/index_abstract.dart';
import 'package:wuchuheng_imap_cache/src/utils/symbol_util/cache_symbol_util.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

import '../../dao/db.dart';

class ImapDirectoryService implements ImapDirectoryServiceAbstract {
  late String _path;
  late ImapClientService _imapClientService;
  late LocalSQLite _localSQLite;

  ImapDirectoryService({
    required String path,
    required ImapClientService imapClientService,
    required LocalSQLite localSQLite,
  }) {
    _path = path;
    _imapClientService = imapClientService;
    _localSQLite = localSQLite;
  }

  @override
  Future<bool> create({int retryCount = 0}) async {
    final client = await _imapClientService.getClient();
    try {
      await client.createMailbox(path);
    } on ImapException catch (e) {
      String expectMessage = 'Unable to find just created mailbox with the path [$path]. Please report this problem.';
      if (retryCount < 5 && e.message == expectMessage) {
        await Future.delayed(const Duration(seconds: 1));
        return await create(retryCount: retryCount + 1);
      } else {
        rethrow;
      }
    }
    return false;
  }

  @override
  Future<void> createFile({required String fileName, required String content}) async {
    final client = await _imapClientService.getClient();
    try {
      final builder = MessageBuilder()
        ..addText(content)
        ..subject = fileName;
      await client.appendMessage(builder.buildMimeMessage());
    } on ImapException catch (e, track) {
      print(e);
      print(track);
      rethrow;
    }
  }

  @override
  Future<void> deleteFileByUid(int uid) async {
    Logger.info('Start using uid: $uid to delete online data.');
    final client = await _imapClientService.getClient();
    final sequence = MessageSequence.fromId(uid, isUid: true);
    await client.uidStore(sequence, ["\\Deleted"]);
    await client.uidExpunge(sequence);
    Logger.info('Complete using uid: $uid to delete online data.');
  }

  @override
  Future<bool> exists() async {
    final client = await _imapClientService.getClient();
    final mailboxes = await client.listMailboxes();
    for (var mailbox in mailboxes) {
      if (mailbox.name == path) return true;
    }
    return false;
  }

  @override
  Future<String?> getFileByUid(int uid) async {
    Logger.info('Get online data by uid: $uid');
    ImapClient client = await _imapClientService.getClient();
    final data = await client.uidFetchMessage(uid, 'BODY[]');
    if (data.messages.isEmpty) {
      throw NotFoundEmailError();
    }
    String? body = data.messages[0].decodeTextPlainPart();
    return body!.replaceAll(RegExp(r'\r\n'), '');
  }

  @override
  Future<List<SubjectInfo>> getFiles() async {
    final client = await _imapClientService.getClient();
    final uid = await _localSQLite.onlineCacheInfoDao().fetchLastUid();
    final MessageSequence sequence = MessageSequence.fromRangeToLast(uid);

    final FetchImapResult onlineData = await client.uidFetchMessages(sequence, 'BODY.PEEK[HEADER.FIELDS (subject)]');
    final List<SubjectInfo> result = [];
    Map<String, SubjectInfo> keyMapSubjectInfo = {};
    onlineData.messages.removeAt(0);
    for (final message in onlineData.messages) {
      message.sequenceId;
      String? symbol = message.getHeaderValue('Subject');
      if (symbol != null) {
        symbol = CacheSymbolUtil.fromSymbol(symbol).toString();
        final SubjectInfo subjectInfo = SubjectInfo(message.uid!, CacheSymbolUtil.fromSymbol(symbol));
        if (keyMapSubjectInfo.containsKey(subjectInfo.symbol.key)) {
          // Delete old data on line
          final SubjectInfo prevSubjectInfo = keyMapSubjectInfo[subjectInfo.symbol.key]!;
          final prevUpdateAtTimestamp = prevSubjectInfo.symbol.updatedAt.microsecondsSinceEpoch;
          if (prevUpdateAtTimestamp < subjectInfo.symbol.updatedAt.microsecondsSinceEpoch) {
            Logger.info(
              'Delete the last duplicate old data for online, symbol: ${prevSubjectInfo.symbol.toString()} uid: ${prevSubjectInfo.uid} ',
            );
            try {
              await deleteFileByUid(prevSubjectInfo.uid);
            } catch (e) {
              Logger.error('Failed to delete online data. symbol: ${prevSubjectInfo.symbol.toString()}');
            }
            keyMapSubjectInfo[subjectInfo.symbol.key] = subjectInfo;
          } else {
            Logger.info('Delete Online Data, symbol: $symbol uid: ${message.uid!} ');
            try {
              await deleteFileByUid(subjectInfo.uid);
            } catch (e) {
              Logger.error('Failed to delete online data. symbol: ${subjectInfo.symbol.toString()}');
            }
          }
        } else {
          keyMapSubjectInfo[subjectInfo.symbol.key] = SubjectInfo(message.uid!, CacheSymbolUtil.fromSymbol(symbol));
        }
      }
    }

    for (var element in keyMapSubjectInfo.values) {
      CacheInfoModel? cacheInfo = await _localSQLite.cacheInfoDao().findBySymbol(element.symbol.toString());
      if (cacheInfo == null) result.add(element);
    }

    return result;
  }

  @override
  String get path => _path;

  @override
  Future<Mailbox> selectPath() async {
    final client = await _imapClientService.getClient();
    return await client.selectMailboxByPath(path);
  }
}
