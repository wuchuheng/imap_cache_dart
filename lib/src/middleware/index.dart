import 'dart:convert';
import 'dart:isolate';

import 'package:imap_cache/src/dto/connect_config/index.dart';
import 'package:imap_cache/src/dto/isolate_response/index.dart';
import 'package:imap_cache/src/service/imap_cache_service/index.dart';
import 'package:imap_cache/src/service/imap_cache_service/index_abstarct.dart';

import '../dto/isolate_request/index.dart';

typedef IsolateCallback = Future<IsolateResponse> Function(IsolateRequest isolateData);

Future<IsolateCallback> IsolateMiddleware() async {
  ReceivePort receivePort = ReceivePort();
  Isolate.spawn<SendPort>(heavyComputationTask, receivePort.sendPort);
  SendPort sendPort = await receivePort.first;
  return (IsolateRequest isolateData) async {
    ReceivePort responseReceivePort = ReceivePort();
    sendPort.send([jsonEncode(isolateData), responseReceivePort.sendPort]);
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
      switch (requestData.dateType) {
        case DateType.CONNECT:
          connectToServer(message[1], requestData, imapCacheService);
          break;
      }
    }
  }
}

Future connectToServer(
    SendPort sendPort, IsolateRequest isolateRequest, ImapCacheServiceAbstract imapCacheService) async {
  final config = ConnectConfig.fromJson(jsonDecode(isolateRequest.data));
  late IsolateResponse response;
  try {
    await imapCacheService.connectToServer(config);
    response = IsolateResponse(isSuccess: true);
  } catch (e) {
    response = IsolateResponse(isSuccess: false, error: e.toString());
  }
  sendPort.send(jsonEncode(response));
}
