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

import '../../wuchuheng_imap_cache.dart';
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
  ImapCacheServiceI imapCacheService = ImapCacheServiceI();
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
      case ChannelName.afterSync:
        onAfterSync(channel, imapCacheService, message);
        break;
      case ChannelName.beforeSync:
        onBeforeSync(channel, imapCacheService, message);
        break;
      case ChannelName.setSyncInterval:
        onSetSyncInterval(channel, imapCacheService, message);
        break;
      case ChannelName.onUpdate:
        onUpdate(channel, imapCacheService, message);
        break;
      case ChannelName.onUpdated:
        onUpdated(channel, imapCacheService, message);
        break;
      case ChannelName.onDownload:
        onDownload(channel, imapCacheService, message);
        break;
      case ChannelName.onDownloaded:
        onDownloaded(channel, imapCacheService, message);
        break;
    }
  });
}

/// The event to downloaded data from online to local.
void onDownloaded(ChannelAbstract channel, ImapCacheServiceI imapCacheService, String message) {
  final unsubscribe = imapCacheService.onDownloaded(() => channel.send(''));
  channel.onClose((value) => unsubscribe.unsubscribe());
}

/// The event to download data from online to local.
void onDownload(ChannelAbstract channel, ImapCacheServiceI imapCacheService, String message) {
  final unsubscribe = imapCacheService.onDownload(() => channel.send(''));
  channel.onClose((value) => unsubscribe.unsubscribe());
}

/// completed the uploading data to the server.
void onUpdated(ChannelAbstract channel, ImapCacheServiceI imapCacheService, String message) {
  final unsubscribe = imapCacheService.onUpdated(() => channel.send(''));
  channel.onClose((value) => unsubscribe.unsubscribe());
}

/// Start uploading data to the server.
void onUpdate(ChannelAbstract channel, ImapCacheServiceI imapCacheService, String message) {
  final unsubscribe = imapCacheService.onUpdate(() => channel.send(''));
  channel.onClose((value) => unsubscribe.unsubscribe());
}

void onSetSyncInterval(ChannelAbstract channel, ImapCacheService imapCacheService, String message) {
  imapCacheService.setSyncInterval(int.parse(message));
  channel.send('');
}

void onBeforeSync(ChannelAbstract channel, ImapCacheService imapCacheService, String message) {
  final unsubscribe = imapCacheService.beforeSync((duration) {
    channel.send(duration.inSeconds.toString());
  });
  channel.onClose((name) => unsubscribe.unsubscribe());
}

void onAfterSync(ChannelAbstract channel, ImapCacheService imapCacheService, String message) {
  final unsubscribe = imapCacheService.afterSync((duration) => channel.send(duration.inSeconds.toString()));
  channel.onClose((name) => unsubscribe.unsubscribe());
}

void onDisconnect(ChannelAbstract channel, ImapCacheServiceI imapCacheService, String message) {
  imapCacheService.disconnect();
  channel.send('');
}

void onSubjectLog(ChannelAbstract channel, ImapCacheServiceI imapCacheService, String message) {
  final unsubscribe = imapCacheService.subscribeLog((loggerItem) {
    channel.send(jsonEncode(loggerItem));
  });
  channel.onClose((name) => unsubscribe.unsubscribe());
}

Map<int, SubjectHook<void>> idMapAfterSet = {};
void onAfterSet(ChannelAbstract channel, ImapCacheServiceI imapCacheService, String message) {
  if (!afterSetChannelId.contains(channel.channelId)) {
    final String? key = message.isEmpty ? null : message;
    afterSetChannelId.add(channel.channelId);
    final subscribe = imapCacheService.afterSet(
        key: key,
        callback: ({required key, required value, required hash, required from}) async {
          idMapAfterSet[channel.channelId] = SubjectHook<void>();
          channel.send(jsonEncode(CallbackData(key: key, value: value, hash: hash, from: from)));
          await idMapAfterSet[channel.channelId]?.toFuture();
        });
    channel.onClose((name) {
      afterSetChannelId.remove(channel.channelId);
      subscribe.unsubscribe();
      idMapAfterSet.removeWhere((key, value) => key == channel.channelId);
    });
  } else {
    idMapAfterSet[channel.channelId]?.next(null);
  }
}

Map<int, Completer<void>> idMapUnset = {};
void onUnset(ChannelAbstract channel, ImapCacheServiceI imapCacheService, String message) {
  if (!afterUnsetChannelId.contains(channel.channelId)) {
    afterUnsetChannelId.add(channel.channelId);
    final String? key = message.isEmpty ? null : message;
    final subscribe = imapCacheService.afterUnset(
        key: key,
        callback: ({required key}) async {
          idMapUnset[channel.channelId] = Completer();
          channel.send(key);
          await idMapUnset[channel.channelId]?.future;
        });
    channel.onClose((name) {
      afterUnsetChannelId.remove(channel.channelId);
      subscribe.unsubscribe();
      idMapUnset.removeWhere((key, value) => key == channel.channelId);
    });
  } else {
    idMapUnset[channel.channelId]?.complete(null);
  }
}

Map<int, SubjectHook<CallbackData>> idMapBeforeSet = {};
void onBeforeSet(ChannelAbstract channel, ImapCacheServiceI imapCacheService, String message) {
  if (!beforeSetChannelId.contains(channel.channelId)) {
    beforeSetChannelId.add(channel.channelId);
    final subscribe = imapCacheService.beforeSet(
      key: message.isEmpty ? null : message,
      callback: ({required String key, required String value, required String hash, required From from}) async {
        idMapBeforeSet[channel.channelId] = SubjectHook<CallbackData>();
        channel.send(jsonEncode(CallbackData(key: key, value: value, hash: hash, from: from)));
        final callData = await idMapBeforeSet[channel.channelId]!.toFuture();
        return callData.value;
      },
    );
    channel.onClose((name) {
      beforeSetChannelId.remove(channel.channelId);
      subscribe.unsubscribe();
      idMapBeforeSet.removeWhere((key, value) => key == channel.channelId);
    });
  } else {
    final callbackData = CallbackData.fromJson(jsonDecode(message));
    idMapBeforeSet[channel.channelId]?.next(callbackData);
  }
}

Map<int, SubjectHook<bool>> idMapBeforeUnSet = {};
void onBeforeUnset(ChannelAbstract channel, ImapCacheServiceI imapCacheService, String message) {
  if (!beforeUnsetChannelId.contains(channel.channelId)) {
    beforeUnsetChannelId.add(channel.channelId);
    final subscribe = imapCacheService.beforeUnset(
      key: message.isEmpty ? null : message,
      callback: ({required String key}) async {
        idMapBeforeUnSet[channel.channelId] = SubjectHook<bool>();
        channel.send(key);
        final result = await idMapBeforeUnSet[channel.channelId]!.toFuture();
        return result;
      },
    );
    channel.onClose((name) {
      subscribe.unsubscribe();
      beforeUnsetChannelId.remove(channel.channelId);
      idMapBeforeUnSet.removeWhere((key, value) => key == channel.channelId);
    });
  } else {
    final ResultData result = ResultData.fromJson(jsonDecode(message));
    idMapBeforeUnSet[channel.channelId]?.next(result.result);
  }
}
