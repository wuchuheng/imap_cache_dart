import 'dart:async';
import 'dart:convert';

import 'package:imap_cache/src/middleware/index.dart';
import 'package:imap_cache/src/service/imap_cache_service/index_abstarct.dart';
import 'package:imap_cache/src/subscription/subscription_abstract.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

import 'dto/connect_config/index.dart';
import 'dto/isolate_request/index.dart';
import 'errors/connect_error.dart';

class ImapCache implements ImapCacheServiceAbstract {
  late IsolateCallback isolateMiddleware;

  @override
  Future<ImapCacheServiceAbstract> connectToServer(ConnectConfig config) async {
    isolateMiddleware = await IsolateMiddleware();
    final response = await isolateMiddleware(IsolateRequest(dateType: DateType.CONNECT, data: jsonEncode(config)));
    if (response.isSuccess) {
      return this;
    } else {
      Logger.error(response.error ?? '');
      throw ConnectError();
    }
  }

  @override
  UnsubscribeAbstract afterSet({String? key, required AfterSetCallback callback}) {
    // TODO: implement afterSet
    throw UnimplementedError();
  }

  @override
  UnsubscribeAbstract afterUnset({String? key, required AfterUnsetCallback callback}) {
    // TODO: implement afterUnset
    throw UnimplementedError();
  }

  @override
  UnsubscribeAbstract beforeSet({String? key, required BeforeSetCallback callback}) {
    // TODO: implement beforeSet
    throw UnimplementedError();
  }

  @override
  UnsubscribeAbstract beforeUnset({String? key, required BeforeUnsetCallback callback}) {
    // TODO: implement beforeUnset
    throw UnimplementedError();
  }

  @override
  Future<String> get({required String key}) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<String?> has({required String key}) {
    // TODO: implement has
    throw UnimplementedError();
  }

  @override
  Future<void> set({required String key, required String value}) {
    // TODO: implement set
    throw UnimplementedError();
  }

  @override
  Future<void> unset({required String key}) {
    // TODO: implement unset
    throw UnimplementedError();
  }
}
