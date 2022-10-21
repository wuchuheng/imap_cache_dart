import 'dart:async';
import 'dart:convert';

import 'package:wuchuheng_hooks/wuchuheng_hooks.dart' as hook;
import 'package:wuchuheng_hooks/wuchuheng_hooks.dart';
import 'package:wuchuheng_imap_cache/src/dto/before_unset/result_data/index.dart';
import 'package:wuchuheng_imap_cache/src/dto/callback_data/index.dart';
import 'package:wuchuheng_imap_cache/src/dto/channel_name.dart';
import 'package:wuchuheng_imap_cache/src/dto/set_data/index.dart';
import 'package:wuchuheng_imap_cache/src/middleware/index.dart';
import 'package:wuchuheng_imap_cache/src/service/imap_cache_service/index_abstarct.dart';
import 'package:wuchuheng_imap_cache/src/service/sync_service/sync_event.dart';
import 'package:wuchuheng_imap_cache/src/subscription/subscription_abstract.dart';
import 'package:wuchuheng_isolate_channel/wuchuheng_isolate_channel.dart';
import 'package:wuchuheng_logger/wuchuheng_logger.dart';

import 'dto/connect_config/index.dart';

class ImapCache implements ImapCacheService {
  late Task task;

  @override
  Future<ImapCacheService> connectToServer(ConnectConfig config) async {
    task = await middleware();
    final connectChannel = task.createChannel(name: ChannelName.connect.name);
    final result$ = connectChannel.listenToFuture();
    Completer<ImapCacheService> completer = Completer();
    connectChannel.onError((e) {
      completer.completeError(e);
      connectChannel.close();
    });
    connectChannel.send(jsonEncode(config));
    result$.then((value) {
      completer.complete(this);
      connectChannel.close();
    });
    return completer.future;
  }

  @override
  Unsubscribe afterSet({String? key, required AfterSetCallback callback}) {
    final channel = task.createChannel(name: ChannelName.afterSet.name);
    channel.listen((message, channel) async {
      final callbackData = CallbackData.fromJson(jsonDecode(message));
      await callback(
        key: callbackData.key,
        value: callbackData.value,
        hash: callbackData.hash,
        from: callbackData.from,
      );
      channel.send('');
    });
    channel.send(key ?? '');
    channel.onError((e) => throw e);
    return Unsubscribe(() {
      channel.close();
      return true;
    });
  }

  @override
  Unsubscribe afterUnset({String? key, required AfterUnsetCallback callback}) {
    final channel = task.createChannel(name: ChannelName.afterUnset.name);
    channel.listen((message, channel) async {
      await callback(key: message);
      channel.send('');
    });
    channel.send(key ?? '');
    channel.onError((e) => throw e);
    return Unsubscribe(() {
      channel.close();
      return true;
    });
  }

  @override
  Unsubscribe beforeSet({String? key, required BeforeSetCallback callback}) {
    final channel = task.createChannel(name: ChannelName.beforeSet.name);
    channel.listen((message, channel) async {
      final callbackData = CallbackData.fromJson(jsonDecode(message));
      final newResult = await callback(
        key: callbackData.key,
        value: callbackData.value,
        hash: callbackData.hash,
        from: callbackData.from,
      );
      callbackData.value = newResult;
      channel.send(jsonEncode(callbackData));
    });
    channel.send(key ?? '');
    channel.onError((e) => throw e);
    return Unsubscribe(() {
      channel.close();
      return true;
    });
  }

  @override
  Unsubscribe beforeUnset({String? key, required BeforeUnsetCallback callback}) {
    final channel = task.createChannel(name: ChannelName.beforeUnset.name);
    channel.listen((message, channel) async {
      final result = await callback(key: message);
      final data = jsonEncode(ResultData(result: result));
      channel.send(data);
    });
    channel.send(key ?? '');
    channel.onError((e) => throw e);
    return Unsubscribe(() {
      channel.close();
      return true;
    });
  }

  @override
  Future<String> get({required String key}) async {
    final channel = task.createChannel(name: ChannelName.get.name);
    final result$ = channel.listenToFuture();
    channel.send(key);
    channel.onError((e) => throw e);
    final result = await result$;
    channel.close();
    return result;
  }

  @override
  Future<String?> has({required String key}) async {
    final channel = task.createChannel(name: ChannelName.has.name);
    final $result = channel.listenToFuture();
    channel.send(key);
    channel.onError((e) => throw e);
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
    channel.onError((e) => throw e);
    await result$;
    channel.close();
  }

  @override
  Future<void> unset({required String key}) async {
    final channel = task.createChannel(name: ChannelName.unset.name);
    final result$ = channel.listenToFuture();
    channel.send(key);
    channel.onError((e) => throw e);
    await result$;
    channel.close();
  }

  final hook.SubjectHook<LoggerItem> _subjectHook = hook.SubjectHook();

  @override
  Unsubscribe subscribeLog(void Function(LoggerItem loggerItem) callback) {
    final result = _subjectHook.subscribe((value) => callback(value));
    final channel = task.createChannel(name: ChannelName.subjectLog.name);
    channel.listen((message, channel) async {
      Map<String, dynamic> mapData = jsonDecode(message);
      final loggerItem = LoggerItem.fromJson(mapData);
      _subjectHook.next(loggerItem);
    });
    channel.send('');

    return Unsubscribe(() {
      result.unsubscribe();
      channel.close();
      return true;
    });
  }

  @override
  Future<void> disconnect() {
    Completer<void> result = Completer();
    final channel = task.createChannel(name: ChannelName.disconnect.name);
    channel.listen((message, _) async {
      result.complete();
      channel.close();
    });
    channel.send('');
    channel.onError((e) {
      result.completeError(Exception());
      channel.close();
    });

    return result.future;
  }

  @override
  hook.Unsubscribe afterSync(AfterSyncCallback callback) {
    final channel = task.createChannel(name: ChannelName.afterSync.name);
    channel.listen((message, channel) async => callback(Duration(seconds: int.parse(message))));
    channel.send('');

    return hook.Unsubscribe(() {
      channel.close();
      return true;
    });
  }

  @override
  hook.Unsubscribe beforeSync(BeforeSyncCallback callback) {
    final channel = task.createChannel(name: ChannelName.beforeSync.name);
    channel.listen((message, channel) async => callback(Duration(seconds: int.parse(message))));
    channel.send('');

    return hook.Unsubscribe(() {
      channel.close();
      return true;
    });
  }

  @override
  Future<void> setSyncInterval(int second) {
    final result = Completer<void>();
    final channel = task.createChannel(name: ChannelName.setSyncInterval.name);
    channel.listen((message, channel) async {
      result.complete();
      channel.close();
    });
    channel.send(second.toString());

    return result.future;
  }

  @override
  hook.Unsubscribe onUpdate(void Function() callback) {
    final channel = task.createChannel(name: ChannelName.onUpdate.name);
    channel.listen((message, channel) async => {callback()});
    channel.send('');

    return hook.Unsubscribe(() {
      channel.close();
      return true;
    });
  }

  @override
  hook.Unsubscribe onUpdated(void Function() callback) {
    final channel = task.createChannel(name: ChannelName.onUpdated.name);
    channel.listen((message, channel) async => {callback()});
    channel.send('');

    return hook.Unsubscribe(() {
      channel.close();
      return true;
    });
  }

  @override
  hook.Unsubscribe onDownload(void Function() callback) {
    final channel = task.createChannel(name: ChannelName.onDownload.name);
    channel.listen((message, channel) async => {callback()});
    channel.send('');

    return hook.Unsubscribe(() {
      channel.close();
      return true;
    });
  }

  @override
  hook.Unsubscribe onDownloaded(void Function() callback) {
    final channel = task.createChannel(name: ChannelName.onDownloaded.name);
    channel.listen((message, channel) async => {callback()});
    channel.send('');

    return hook.Unsubscribe(() {
      channel.close();
      return true;
    });
  }
}
