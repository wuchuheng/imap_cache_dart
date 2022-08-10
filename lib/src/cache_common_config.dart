class CacheCommonConfig {
  static String _userName = '';
  static String get userName => _userName;

  static set userName(String value) => _userName = value;

  static String registerSymbol = '__register'; // 注册数据缓存名
}
