import 'package:imap_cache/src/subscription/subscription_abstract.dart';

class Unsubscription implements UnsubscribeAbstract {
  final void Function() _unsubscribe;

  Unsubscription(this._unsubscribe);

  @override
  void unsubscribe() => _unsubscribe();
}