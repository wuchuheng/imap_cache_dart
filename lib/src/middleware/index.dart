import 'dart:convert';
import 'dart:isolate';

import 'package:imap_cache/src/dto/before_unset/result_data/index.dart';
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
        if (!beforeUnsetChannelId.contains(channel.channelId)) {
          beforeUnsetChannelId.add(channel.channelId);
          channel.onClose((name) => beforeUnsetChannelId.remove(channel.channelId));
          imapCacheService.beforeUnset(
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
        }
        break;
    }
  });
}
