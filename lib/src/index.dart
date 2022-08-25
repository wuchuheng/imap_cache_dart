import 'dart:async';
import 'dart:convert';

import 'package:imap_cache/src/dto/isolate_payload/index.dart';
import 'package:imap_cache/src/middleware/index.dart';
import 'package:imap_cache/src/service/imap_cache_service/index_abstarct.dart';
import 'package:imap_cache/src/subscription/subscription_abstract.dart';
import 'package:imap_cache/src/subscription/subscription_imp.dart';
import 'package:imap_cache/src/utils/isolate_util.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

import 'dto/connect_config/index.dart';
import 'dto/isolate_request/index.dart';
import 'errors/connect_error.dart';
import 'errors/set_error.dart';

class ImapCache implements ImapCacheServiceAbstract {
  late IsolateCallback isolateMiddleware;
  late SubscriptionImp _subscriptionImp;

  @override
  Future<ImapCacheServiceAbstract> connectToServer(ConnectConfig config) async {
    isolateMiddleware = await IsolateMiddleware();
    final receivePort = isolateMiddleware(IsolateRequest(dateType: DateType.CONNECT, payload: jsonEncode(config)));
    final response = await receiveToResponse(receivePort);
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
    return _subscriptionImp.beforeSet(key: key, callback: callback);
  }

  @override
  UnsubscribeAbstract beforeUnset({String? key, required BeforeUnsetCallback callback}) {
    return _subscriptionImp.beforeUnset(key: key, callback: callback);
  }

  @override
  Future<String> get({required String key}) async {
    final payload = IsolatePayload(key: key);
    final receivePort = isolateMiddleware(IsolateRequest(dateType: DateType.GET, payload: jsonEncode(payload)));
    final response = await receiveToResponse(receivePort);
    if (!response.isSuccess) {
      Logger.error(response.error ?? '');
      throw SetError();
    }
    return response.data!;
  }

  @override
  Future<String?> has({required String key}) async {
    final payload = jsonEncode(IsolatePayload(key: key));
    final receivePort = isolateMiddleware(IsolateRequest(dateType: DateType.HAS, payload: payload));
    final response = await receiveToResponse(receivePort);
    if (!response.isSuccess) {
      Logger.error(response.error ?? '');
      throw SetError();
    }
    return response.data;
  }

  @override
  Future<void> set({required String key, required String value}) async {
    final payload = IsolatePayload(key: key, value: value);
    final receivePort = isolateMiddleware(IsolateRequest(dateType: DateType.SET, payload: jsonEncode(payload)));
    final response = await receiveToResponse(receivePort);
    if (!response.isSuccess) {
      Logger.error(response.error ?? '');
      throw SetError();
    }
  }

  @override
  Future<void> unset({required String key}) async {
    final payload = IsolatePayload(key: key);
    final receivePort = isolateMiddleware(IsolateRequest(dateType: DateType.UNSET, payload: jsonEncode(payload)));
    final response = await receiveToResponse(receivePort);
    if (!response.isSuccess) {
      Logger.error(response.error ?? '');
      throw SetError();
    }
  }
}
