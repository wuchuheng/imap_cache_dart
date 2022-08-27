import 'dart:convert';
import 'dart:isolate';

import 'package:wuchuheng_imap_cache/src/dto/isolate_request/index.dart';
import 'package:wuchuheng_imap_cache/src/dto/isolate_response/index.dart';

import '../dto/isolate_payload/index.dart';

decodePayload(IsolateRequest isolateRequest) => IsolatePayload.fromJson(jsonDecode(isolateRequest.payload));

sendResponse(SendPort sendPort, IsolateResponse response) => sendPort.send(jsonEncode(response));

Future<IsolateResponse> receiveToResponse(ReceivePort receivePort) async {
  Map<String, dynamic> jsonMap = jsonDecode(await receivePort.first);
  return IsolateResponse.fromJson(jsonMap);
}
