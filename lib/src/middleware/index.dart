import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:imap_cache/src/dto/before_unset/result_data/index.dart';
import 'package:imap_cache/src/dto/callback_data/index.dart';
import 'package:imap_cache/src/dto/channel_name.dart';
import 'package:imap_cache/src/dto/set_data/index.dart';
import 'package:imap_cache/src/service/imap_cache_service/index.dart';
import 'package:wuchuheng_hooks/wuchuheng_hooks.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

import '../dto/connect_config/index.dart';
import '../dto/isolate_request/index.dart';

typedef IsolateCallback = ReceivePort Function(IsolateRequest isolateData);

T enumFromString<T>(List<T> values, String value) {
  return values.firstWhere((v) => v.toString().split('.')[1] == value);
}

List<int> beforeUnsetChannelId = [];
List<int> afterUnsetChannelId = [];
List<int> beforeSetChannelId = [];

Future<Task> middleware() async {
  ImapCacheService imapCacheService = ImapCacheService();
  return await IsolateTask((message, channel) async {
    final ChannelName channelName = enumFromString<ChannelName>(ChannelName.values, channel.name);
    switch (channelName) {
      case ChannelName.connect:
        await imapCacheService.connectToServer(ConnectConfig.fromJson(jsonDecode(message)));
        channel.send('');
        break;
      case ChannelName.set:
        final setData = SetData.fromJson(jsonDecode(message));
        await imapCacheService.set(key: setData.key, value: setData.value);
        channel.send('');
        break;
      case ChannelName.unset:
        await imapCacheService.unset(key: message);
        channel.send('');
        break;
      case ChannelName.has:
        final result = await imapCacheService.has(key: message);
        channel.send(result ?? '');
        break;
      case ChannelName.get:
        final value = await imapCacheService.get(key: message);
        channel.send(value);
        break;
      case ChannelName.beforeUnset:
        onBeforeUnset(channel, imapCacheService, message);
        break;
      case ChannelName.beforeSet:
        onBeforeSet(channel, imapCacheService, message);
        break;
      case ChannelName.afterUnset:
        onUnset(channel, imapCacheService, message);
        break;
    }
  });
}

void onUnset(ChannelAbstract channel, ImapCacheService imapCacheService, String message) {
  if (!afterUnsetChannelId.contains(channel.channelId)) {
    afterUnsetChannelId.add(channel.channelId);
    final String? key = message.isEmpty ? null : message;
    final subscribe = imapCacheService.afterUnset(
        key: key,
        callback: ({required key}) async {
          Completer<void> completer = Completer();
          channel.listen((message, channel) {
            completer.complete(null);
          });
          channel.send(key);
          completer.future;
        });
    channel.onClose((name) {
      afterUnsetChannelId.remove(channel.channelId);
      subscribe.unsubscribe();
    });
  }
}

void onBeforeSet(ChannelAbstract channel, ImapCacheService imapCacheService, String message) {
  if (!beforeSetChannelId.contains(channel.channelId)) {
    beforeSetChannelId.add(channel.channelId);
    final subscribe = imapCacheService.beforeSet(
      key: message.isEmpty ? null : message,
      callback: ({required String key, required String value, required String hash}) async {
        final subject = SubjectHook<CallbackData>();
        channel.listen((message, channel) {
          final callbackData = CallbackData.fromJson(jsonDecode(message));
          subject.next(callbackData);
        });
        channel.send(jsonEncode(CallbackData(key: key, value: value, hash: hash)));
        final callData = await subject.toFuture();
        return callData.value;
      },
    );
    channel.onClose((name) {
      beforeSetChannelId.remove(channel.channelId);
      subscribe.unsubscribe();
    });
  }
}

void onBeforeUnset(ChannelAbstract channel, ImapCacheService imapCacheService, String message) {
  if (!beforeUnsetChannelId.contains(channel.channelId)) {
    beforeUnsetChannelId.add(channel.channelId);
    final subscribe = imapCacheService.beforeUnset(
      key: message.isEmpty ? null : message,
      callback: ({required String key}) async {
        final boolSubject = SubjectHook<bool>();
        channel.listen((message, channel) {
          final result = ResultData.fromJson(jsonDecode(message));
          boolSubject.next(result.result);
        });
        channel.send(key);
        return await boolSubject.toFuture();
      },
    );
    channel.onClose((name) {
      subscribe.unsubscribe();
      beforeUnsetChannelId.remove(channel.channelId);
    });
  }
}
