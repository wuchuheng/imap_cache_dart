import 'dart:convert';
import 'dart:isolate';

import 'package:imap_cache/src/dto/isolate_request/index.dart';
import 'package:imap_cache/src/dto/isolate_response/index.dart';

import '../dto/isolate_payload/index.dart';

decodePayload(IsolateRequest isolateRequest) => IsolatePayload.fromJson(jsonDecode(isolateRequest.payload));

sendResponse(SendPort sendPort, IsolateResponse response) => sendPort.send(jsonEncode(response));