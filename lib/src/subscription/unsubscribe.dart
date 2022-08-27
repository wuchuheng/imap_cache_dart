import 'package:wuchuheng_imap_cache/src/subscription/subscription_abstract.dart';

class Unsubscribe implements UnsubscribeAbstract {
  final void Function() _unsubscribe;

  Unsubscribe(this._unsubscribe);

  @override
  void unsubscribe() => _unsubscribe();
}
