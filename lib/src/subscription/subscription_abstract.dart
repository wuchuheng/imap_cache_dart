import 'package:wuchuheng_hooks/wuchuheng_hooks.dart';

enum From { local, online }

typedef BeforeSetCallback = Future<String> Function({
  required String key,
  required String value,
  required String hash,
  required From from,
});
typedef AfterSetCallback = Future<void> Function({
  required String key,
  required String value,
  required String hash,
  required From from,
});
typedef BeforeUnsetCallback = Future<bool> Function({required String key});
typedef AfterUnsetCallback = Future<void> Function({required String key});

abstract class SubscriptionAbstract {
  Unsubscribe beforeSet({String? key, required BeforeSetCallback callback});
  Unsubscribe afterSet({String? key, required AfterSetCallback callback});
  Unsubscribe beforeUnset({String? key, required BeforeUnsetCallback callback});
  Unsubscribe afterUnset({String? key, required AfterUnsetCallback callback});
}
