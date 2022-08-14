abstract class UnsubscribeAbstract {
  void unsubscribe();
}

abstract class SubscriptionAbstract {}

typedef BeforeSetCallback = Future<String> Function(String value);

abstract class SubscriptionFactoryAbstract {
  UnsubscribeAbstract beforeSetSubscribe({
    required String key,
    required BeforeSetCallback callback,
  });
  UnsubscribeAbstract afterSetSubscribe({required String key, required void Function(String value) callback});
  UnsubscribeAbstract unsetEventSubscribe(
      {required String key, required void Function({required String key}) callback});
}
