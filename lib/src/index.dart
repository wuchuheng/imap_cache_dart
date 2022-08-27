import 'dart:async';
import 'dart:convert';

import 'package:imap_cache/src/dto/before_unset/result_data/index.dart';
import 'package:imap_cache/src/dto/callback_data/index.dart';
import 'package:imap_cache/src/dto/channel_name.dart';
import 'package:imap_cache/src/dto/set_data/index.dart';
import 'package:imap_cache/src/middleware/index.dart';
import 'package:imap_cache/src/service/imap_cache_service/index_abstarct.dart';
import 'package:imap_cache/src/subscription/subscription_abstract.dart';
import 'package:imap_cache/src/subscription/unsubscribe.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';

import 'dto/connect_config/index.dart';

class ImapCache implements ImapCacheServiceAbstract {
  late IsolateCallback isolateMiddleware;
  late Task task;

  @override
  Future<ImapCacheServiceAbstract> connectToServer(ConnectConfig config) async {
    task = await middleware();
    final connectChannel = task.createChannel(name: ChannelName.connect.name);
    final result$ = connectChannel.listenToFuture();
    connectChannel.onError((e) => throw e);
    connectChannel.send(jsonEncode(config));
    await result$;
    connectChannel.close();
    return this;
  }

  @override
  UnsubscribeAbstract afterSet({String? key, required AfterSetCallback callback}) {
    final channel = task.createChannel(name: ChannelName.afterSet.name);
    channel.listen((message, channel) async {
      final callbackData = CallbackData.fromJson(jsonDecode(message));
      await callback(key: callbackData.key, value: callbackData.value, hash: callbackData.hash);
      channel.send('');
    });
    channel.send(key ?? '');
    return Unsubscribe(() {
      channel.close();
    });
  }

  @override
  UnsubscribeAbstract afterUnset({String? key, required AfterUnsetCallback callback}) {
    final channel = task.createChannel(name: ChannelName.afterUnset.name);
    channel.listen((message, channel) async {
      await callback(key: message);
      channel.send('');
    });
    channel.send(key ?? '');
    return Unsubscribe(() => channel.close());
  }

  @override
  UnsubscribeAbstract beforeSet({String? key, required BeforeSetCallback callback}) {
    final channel = task.createChannel(name: ChannelName.beforeSet.name);
    channel.listen((message, channel) async {
      final callbackData = CallbackData.fromJson(jsonDecode(message));
      final newResult = await callback(key: callbackData.key, value: callbackData.value, hash: callbackData.hash);
      callbackData.value = newResult;
      channel.send(jsonEncode(callbackData));
    });
    channel.send(key ?? '');
    return Unsubscribe(() => channel.close());
  }

  @override
  UnsubscribeAbstract beforeUnset({String? key, required BeforeUnsetCallback callback}) {
    final channel = task.createChannel(name: ChannelName.beforeUnset.name);
    channel.listen((message, channel) async {
      final result = await callback(key: message);
      final data = jsonEncode(ResultData(result: result));
      channel.send(data);
    });
    channel.send(key ?? '');
    channel.onError((e) => throw e);
    return Unsubscribe(() => channel.close());
  }

  @override
  Future<String> get({required String key}) async {
    final channel = task.createChannel(name: ChannelName.get.name);
    final result$ = channel.listenToFuture();
    channel.send(key);
    final result = await result$;
    channel.close();
    return result;
  }

  @override
  Future<String?> has({required String key}) async {
    final channel = task.createChannel(name: ChannelName.has.name);
    final $result = channel.listenToFuture();
    channel.send(key);
    final result = await $result;
    channel.close();
    return result.isEmpty ? null : result;
  }

  @override
  Future<void> set({required String key, required String value}) async {
    final payload = jsonEncode(SetData(key: key, value: value));
    final channel = task.createChannel(name: ChannelName.set.name);
    final result$ = channel.listenToFuture();
    channel.send(payload);
    await result$;
    channel.close();
  }

  @override
  Future<void> unset({required String key}) async {
    final channel = task.createChannel(name: ChannelName.unset.name);
    final result$ = channel.listenToFuture();
    channel.send(key);
    await result$;
    channel.close();
  }
}
