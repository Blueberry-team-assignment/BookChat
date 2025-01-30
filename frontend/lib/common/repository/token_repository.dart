import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenRepository {
  Future<void> setToken(String token);
  Future<String?> getToken();
  Future deleteToken();
}

class SecureStorageTokenRepository implements TokenRepository {
  final _storage = const FlutterSecureStorage();

  @override
  Future<void> setToken(String token) async =>
      await _storage.write(key: 'auth_token', value: token);

  @override
  Future<String?> getToken() async =>
      await _storage.read(key: 'auth_token');

  @override
  Future<void> deleteToken() async =>
      await _storage.delete(key: 'auth_token');
}