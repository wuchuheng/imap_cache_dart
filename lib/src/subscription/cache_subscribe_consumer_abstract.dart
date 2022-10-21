import 'package:wuchuheng_imap_cache/src/subscription/subscription_abstract.dart';

abstract class CacheSubscribeConsumerAbstract {
  Future<bool> beforeUnsetConsume({required String key});

  Future<void> afterUnsetSubscribeConsume({required String key});

  /// Processing of consumption of beforeSet subscription event.
  Future<String> beforeSetSubscribeConsume({required String key, required String value, required From from});

  /// Processing of consumption of beforeSet subscription event.
  void afterSetSubscribeConsume({required String key, required String value, required From from});
}
