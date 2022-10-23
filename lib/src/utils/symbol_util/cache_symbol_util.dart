import '../hash.dart';

class CacheSymbolUtil {
  static final _prefix = 'cache';
  static final _splitSymbol = '#';

  DateTime updatedAt;
  DateTime? deletedAt;
  String key;
  String hash = '';
  String value;

  CacheSymbolUtil({
    required this.updatedAt,
    required this.key,
    required this.value,
    this.deletedAt,
  });

  /// Generate a symbol for the persistent cache
  @override
  String toString() {
    hash = Hash.convertStringToHash(value);
    final deletedAtSymbol = deletedAt != null ? deletedAt!.microsecondsSinceEpoch : '';
    return '$_prefix$_splitSymbol$key$_splitSymbol${updatedAt.microsecondsSinceEpoch}$_splitSymbol$hash$_splitSymbol$deletedAtSymbol';
  }

  CacheSymbolUtil.fromSymbol(String symbol)
      : key = '',
        value = '',
        updatedAt = DateTime.now() {
    final listStr = symbol.split(_splitSymbol);
    key = listStr[1];
    updatedAt = DateTime.fromMicrosecondsSinceEpoch(int.parse(listStr[2]));
    hash = listStr[3];
    hash = hash.replaceAll(RegExp(r'\r\n'), '');
    hash = hash.replaceAll(RegExp(r'\s+'), '');

    if (listStr[4].isNotEmpty) deletedAt = DateTime.fromMicrosecondsSinceEpoch(int.parse(listStr[4]));
  }
}
