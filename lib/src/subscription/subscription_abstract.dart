abstract class UnsubscribeAbstract {
  void unsubscribe();
}

abstract class SubscriptionAbstract {}

abstract class SubscriptionFactoryAbstract {
  UnsubscribeAbstract beforeSetSubscribe({required String key, required void Function(String value) callback});
  UnsubscribeAbstract afterSetSubscribe({required String key, required void Function(String value) callback});
  UnsubscribeAbstract unsetEventSubscribe(
      {required String key, required void Function({required String key}) callback});
}
