import '../hash.dart';

class CacheSymbolUtil {
  static final _prefix = 'cache';
  static final _splitSymbol = '#';

  DateTime updatedAt;
  String key;
  String hash = '';
  String value;

  CacheSymbolUtil({
    required this.updatedAt,
    required this.key,
    required this.value,
  });

  /// Generate a symbol for the persistent cache
  @override
  String toString() {
    final hash = Hash.convertStringToHash(value);
    return '$_prefix$_splitSymbol$key$_splitSymbol${updatedAt.microsecondsSinceEpoch}$_splitSymbol$hash';
  }

  CacheSymbolUtil.fromSymbol(String symbol)
      : key = '',
        value = '',
        updatedAt = DateTime.now() {
    final listStr = symbol.split(_splitSymbol);
    key = listStr[1];
    updatedAt = DateTime.fromMicrosecondsSinceEpoch(int.parse(listStr[2]));
    hash = listStr[3];
  }
}
