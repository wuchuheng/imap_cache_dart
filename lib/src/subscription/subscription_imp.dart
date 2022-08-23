import 'package:imap_cache/src/subscription/subscription_abstract.dart';
import 'package:imap_cache/src/subscription/unsubscribe.dart';

import '../utils/hash.dart';
import 'cache_subscribe_consumer_abstract.dart';

class SubscriptionImp implements SubscriptionAbstract, CacheSubscribeConsumerAbstract {
  final Map<String, Map<int, BeforeSetCallback>> _beforeSetSubscribeRegister = {};
  final Map<int, BeforeSetCallback> _globalBeforeSetSubscribeRegister = {};
  final Map<String, Map<int, AfterSetCallback>> _afterSetSubscribeRegister = {};
  final Map<int, AfterSetCallback> _globalAfterSetSubscribeRegister = {};
  final Map<String, Map<int, BeforeUnsetCallback>> _beforeUnsetSubscribeRegister = {};
  final Map<int, BeforeUnsetCallback> _globalBeforeUnsetSubscribeRegister = {};
  final Map<String, Map<int, AfterUnsetCallback>> _afterUnsetSubscribeRegister = {};
  final Map<int, AfterUnsetCallback> _globalAfterUnsetSubscribeRegister = {};

  @override
  UnsubscribeAbstract afterSet({String? key, required AfterSetCallback callback}) {
    final id = DateTime.now().microsecondsSinceEpoch;
    if (key != null) {
      if (_afterSetSubscribeRegister.containsKey(key)) _afterSetSubscribeRegister[key] = {};
      _afterSetSubscribeRegister[key]![id] = callback;
      return Unsubscribe(() => _afterSetSubscribeRegister[key]?.remove(id));
    } else {
      _globalAfterSetSubscribeRegister[id] = callback;
      return Unsubscribe(() => _globalAfterSetSubscribeRegister.remove(id));
    }
  }

  @override
  UnsubscribeAbstract beforeSet({String? key, required BeforeSetCallback callback}) {
    final id = DateTime.now().microsecondsSinceEpoch;
    if (key != null) {
      if (!_beforeSetSubscribeRegister.containsKey(key)) _beforeSetSubscribeRegister[key] = {};
      _beforeSetSubscribeRegister[key]![id] = callback;
      return Unsubscribe(() => _beforeSetSubscribeRegister[key]?.remove(id));
    } else {
      _globalBeforeSetSubscribeRegister[id] = callback;
      return Unsubscribe(() => _globalBeforeSetSubscribeRegister.remove(id));
    }
  }

  @override
  UnsubscribeAbstract beforeUnset({String? key, required BeforeUnsetCallback callback}) {
    final id = DateTime.now().microsecondsSinceEpoch;
    if (key != null) {
      if (!_beforeUnsetSubscribeRegister.containsKey(key)) _beforeUnsetSubscribeRegister[key] = {};
      _beforeUnsetSubscribeRegister[key]![id] = callback;
      return Unsubscribe(() => _beforeUnsetSubscribeRegister[key]?.remove(id));
    } else {
      _globalBeforeUnsetSubscribeRegister[id] = callback;
      return Unsubscribe(() => _globalBeforeUnsetSubscribeRegister.remove(id));
    }
  }

  @override
  UnsubscribeAbstract afterUnset({String? key, required AfterUnsetCallback callback}) {
    final id = DateTime.now().microsecondsSinceEpoch;
    if (key != null) {
      if (_afterUnsetSubscribeRegister.containsKey(key)) _afterUnsetSubscribeRegister[key] = {};
      _afterUnsetSubscribeRegister[key]![id] = callback;
      return Unsubscribe(() => _afterUnsetSubscribeRegister[key]?.remove(id));
    } else {
      _globalAfterUnsetSubscribeRegister[id] = callback;
      return Unsubscribe(() => _globalAfterUnsetSubscribeRegister.remove(id));
    }
  }

  @override
  Future<bool> beforeUnsetConsume({required String key}) async {
    if (_beforeUnsetSubscribeRegister.containsKey(key)) {
      for (final id in _beforeUnsetSubscribeRegister[key]!.keys) {
        final callback = _beforeUnsetSubscribeRegister[key]![id];
        if (callback != null) {
          if (!await callback(key: key)) return false;
        }
      }
    }
    for (final id in _globalBeforeUnsetSubscribeRegister.keys) {
      final callback = _globalBeforeUnsetSubscribeRegister[id];
      if (callback != null) {
        if (!await callback(key: key)) return false;
      }
    }

    return true;
  }

  @override
  Future<void> afterUnsetSubscribeConsume({required String key}) async {
    if (_afterUnsetSubscribeRegister.containsKey(key)) {
      for (final id in _afterUnsetSubscribeRegister[key]!.keys) {
        final callback = _afterUnsetSubscribeRegister[key]![id];
        if (callback != null) callback(key: key);
      }
    }
    for (final id in _globalAfterUnsetSubscribeRegister.keys) {
      final callback = _globalAfterUnsetSubscribeRegister[id];
      if (callback != null) callback(key: key);
    }
  }

  /// Processing of consumption of beforeSet subscription event.
  @override
  Future<String> beforeSetSubscribeConsume({required String key, required String value}) async {
    if (_beforeSetSubscribeRegister.containsKey(key)) {
      for (final id in _beforeSetSubscribeRegister[key]!.keys) {
        final callback = _beforeSetSubscribeRegister[key]![id];
        final hash = Hash.convertStringToHash(value);
        if (callback != null) value = await callback(key: key, value: value, hash: hash);
      }
    }
    if (_globalBeforeSetSubscribeRegister.isNotEmpty) {
      for (final id in _globalBeforeSetSubscribeRegister.keys) {
        final callback = _globalBeforeSetSubscribeRegister[id];
        if (callback != null) value = await callback(key: key, value: value, hash: Hash.convertStringToHash(value));
      }
    }

    return value;
  }

  /// Processing of consumption of beforeSet subscription event.
  @override
  void afterSetSubscribeConsume({required String key, required String value}) async {
    if (_afterSetSubscribeRegister.containsKey(key)) {
      for (final id in _afterSetSubscribeRegister[key]!.keys) {
        final callback = _afterSetSubscribeRegister[key]![id];
        if (callback != null) callback(key: key, value: value, hash: Hash.convertStringToHash(value));
      }
    }
    for (final id in _globalAfterSetSubscribeRegister.keys) {
      final callback = _globalAfterSetSubscribeRegister[id];
      final hash = Hash.convertStringToHash(value);
      if (callback != null) callback(key: key, value: value, hash: hash);
    }
  }
}