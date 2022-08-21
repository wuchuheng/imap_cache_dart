abstract class ImapServiceAbstract {
  Future<String> get({required String key});

  Future<void> set({required String key, required String value});

  Future<void> unset({required String key});

  Future<String?> has({required String key});
}
