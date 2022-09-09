import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:wuchuheng_hooks/wuchuheng_hooks.dart';
import 'package:wuchuheng_imap_cache/src/dto/before_unset/result_data/index.dart';
import 'package:wuchuheng_imap_cache/src/dto/callback_data/index.dart';
import 'package:wuchuheng_imap_cache/src/dto/channel_name.dart';
import 'package:wuchuheng_imap_cache/src/dto/set_data/index.dart';
import 'package:wuchuheng_imap_cache/src/service/imap_cache_service/index.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

import '../dto/connect_config/index.dart';
import '../dto/isolate_request/index.dart';

typedef IsolateCallback = ReceivePort Function(IsolateRequest isolateData);

T enumFromString<T>(List<T> values, String value) {
  return values.firstWhere((v) => v.toString().split('.')[1] == value);
}

List<int> beforeUnsetChannelId = [];
List<int> beforeSetChannelId = [];
List<int> afterUnsetChannelId = [];
List<int> afterSetChannelId = [];

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
      case ChannelName.afterSet:
        onAfterSet(channel, imapCacheService, message);
        break;
      case ChannelName.subjectLog:
        onSubjectLog(channel, imapCacheService, message);
        break;
      case ChannelName.disconnect:
        onDisconnect(channel, imapCacheService, message);
        break;
    }
  });
}

void onDisconnect(ChannelAbstract channel, ImapCacheService imapCacheService, String message) {
  imapCacheService.disconnect();
  channel.send('');
}

void onSubjectLog(ChannelAbstract channel, ImapCacheService imapCacheService, String message) {
  final unsubscribe = imapCacheService.subscribeLog((loggerItem) {
    channel.send(jsonEncode(loggerItem));
  });
  channel.onClose((name) => unsubscribe.unsubscribe());
}

void onAfterSet(ChannelAbstract channel, ImapCacheService imapCacheService, String message) {
  if (!afterSetChannelId.contains(channel.channelId)) {
    final String? key = message.isEmpty ? null : message;
    afterSetChannelId.add(channel.channelId);
    final subscribe = imapCacheService.afterSet(
        key: key,
        callback: ({required key, required value, required hash}) async {
          final subject = SubjectHook<void>();
          final listen = channel.listen((message, channel) {
            subject.next(null);
          });
          channel.send(jsonEncode(CallbackData(key: key, value: value, hash: hash)));
          await subject.toFuture();
          listen.cancel();
        });
    channel.onClose((name) {
      afterSetChannelId.remove(channel.channelId);
      subscribe.unsubscribe();
    });
  }
}

void onUnset(ChannelAbstract channel, ImapCacheService imapCacheService, String message) {
  if (!afterUnsetChannelId.contains(channel.channelId)) {
    afterUnsetChannelId.add(channel.channelId);
    final String? key = message.isEmpty ? null : message;
    final subscribe = imapCacheService.afterUnset(
        key: key,
        callback: ({required key}) async {
          Completer<void> completer = Completer();
          final listen = channel.listen((message, channel) {
            completer.complete(null);
          });
          channel.send(key);
          await completer.future;
          listen.cancel();
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
        final listen = channel.listen((message, channel) {
          final callbackData = CallbackData.fromJson(jsonDecode(message));
          subject.next(callbackData);
        });
        channel.send(jsonEncode(CallbackData(key: key, value: value, hash: hash)));
        final callData = await subject.toFuture();
        listen.cancel();
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
        final listen = channel.listen((message, channel) {
          final result = ResultData.fromJson(jsonDecode(message));
          boolSubject.next(result.result);
        });
        channel.send(key);
        final result = await boolSubject.toFuture();
        listen.cancel();
        return result;
      },
    );
    channel.onClose((name) {
      subscribe.unsubscribe();
      beforeUnsetChannelId.remove(channel.channelId);
    });
  }
}
