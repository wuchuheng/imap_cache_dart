abstract class CacheSubscribeConsumerAbstract {
  Future<bool> beforeUnsetConsume({required String key});

  Future<void> afterUnsetSubscribeConsume({required String key});

  /// Processing of consumption of beforeSet subscription event.
  Future<String> beforeSetSubscribeConsume({required String key, required String value});

  /// Processing of consumption of beforeSet subscription event.
  void afterSetSubscribeConsume({required String key, required String value});
}
