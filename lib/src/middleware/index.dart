import 'dart:convert';
import 'dart:isolate';

import 'package:imap_cache/src/dto/connect_config/index.dart';
import 'package:imap_cache/src/dto/isolate_response/index.dart';
import 'package:imap_cache/src/service/imap_cache_service/index.dart';
import 'package:imap_cache/src/service/imap_cache_service/index_abstarct.dart';
import 'package:imap_cache/src/utils/isolate_util.dart';

import '../dto/isolate_request/index.dart';

typedef IsolateCallback = Future<IsolateResponse> Function(IsolateRequest isolateData);

Future<IsolateCallback> IsolateMiddleware() async {
  ReceivePort receivePort = ReceivePort();
  Isolate.spawn<SendPort>(heavyComputationTask, receivePort.sendPort);
  SendPort sendPort = await receivePort.first;
  return (IsolateRequest isolateData) async {
    ReceivePort responseReceivePort = ReceivePort();
    sendPort.send([jsonEncode(isolateData), responseReceivePort.sendPort]);

    /// TODO: 订阅类型要采用for 监听数据变化和相关解除订阅操作
    String response = await responseReceivePort.first;
    Map<String, dynamic> jsonMap = jsonDecode(response);
    return IsolateResponse.fromJson(jsonMap);
  };
}

void heavyComputationTask(SendPort sendPort) async {
  ReceivePort receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  ImapCacheServiceAbstract imapCacheService = ImapCacheService();
  await for (var message in receivePort) {
    if (message is List) {
      final jsonStr = message[0];
      Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
      final IsolateRequest requestData = IsolateRequest.fromJson(jsonMap);
      try {
        switch (requestData.dateType) {
          case DateType.CONNECT:
            connectToServer(message[1], requestData, imapCacheService);
            break;
          case DateType.SET:
            onSet(message[1], requestData, imapCacheService);
            break;
          case DateType.GET:
            onGet(message[1], requestData, imapCacheService);
            break;
          case DateType.UNSET:
            onUnset(message[1], requestData, imapCacheService);
            break;
          case DateType.HAS:
            onHas(message[1], requestData, imapCacheService);
            break;
        }
      } catch (e) {
        message[1].send(jsonEncode(IsolateResponse(isSuccess: false, error: e.toString())));
      }
    }
  }
}

Future<void> onHas(SendPort sendPort, IsolateRequest isolateRequest, ImapCacheServiceAbstract imapCacheService) async {
  final payload = decodePayload(isolateRequest);
  final response = IsolateResponse(isSuccess: true, data: await imapCacheService.has(key: payload.key));
  sendResponse(sendPort, response);
}

Future<void> onUnset(
  SendPort sendPort,
  IsolateRequest isolateRequest,
  ImapCacheServiceAbstract imapCacheService,
) async {
  final payload = decodePayload(isolateRequest);
  await imapCacheService.unset(key: payload.key);
  final response = IsolateResponse(isSuccess: true);
  sendResponse(sendPort, response);
}

Future<void> onGet(SendPort sendPort, IsolateRequest isolateRequest, ImapCacheServiceAbstract imapCacheService) async {
  final payload = decodePayload(isolateRequest);
  final response = IsolateResponse(isSuccess: true, data: await imapCacheService.get(key: payload.key));
  sendPort.send(jsonEncode(response));
}

Future<void> onSet(SendPort sendPort, IsolateRequest isolateRequest, ImapCacheServiceAbstract imapCacheService) async {
  final payload = decodePayload(isolateRequest);
  await imapCacheService.set(key: payload.key, value: payload.value!);
  final response = IsolateResponse(isSuccess: true);
  sendResponse(sendPort, response);
}

Future connectToServer(
  SendPort sendPort,
  IsolateRequest isolateRequest,
  ImapCacheServiceAbstract imapCacheService,
) async {
  final config = ConnectConfig.fromJson(jsonDecode(isolateRequest.payload));
  late IsolateResponse response;
  await imapCacheService.connectToServer(config);
  response = IsolateResponse(isSuccess: true);
  sendResponse(sendPort, response);
}
