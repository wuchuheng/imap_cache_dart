abstract class UnsubscribeAbstract {
  void unsubscribe();
}

typedef BeforeSetCallback = Future<String> Function({required String key, required String value, required String hash});
typedef AfterSetCallback = Future<void> Function({required String key, required String value, required String hash});
typedef BeforeUnsetCallback = Future<bool> Function({required String key});
typedef AfterUnsetCallback = Future<void> Function({required String key});

abstract class SubscriptionAbstract {
  UnsubscribeAbstract beforeSet({String? key, required BeforeSetCallback callback});
  UnsubscribeAbstract afterSet({String? key, required AfterSetCallback callback});
  UnsubscribeAbstract beforeUnset({String? key, required BeforeUnsetCallback callback});
  UnsubscribeAbstract afterUnset({String? key, required AfterUnsetCallback callback});
}
