import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final tokenRepositoryProvider = Provider<TokenRepository>((ref){
  return SecureStorageTokenRepository();
});

abstract class TokenRepository {
  Future<void> setToken(String key, String token);
  Future<String?> getToken(String key);
  Future deleteToken(String key);
}

class SecureStorageTokenRepository implements TokenRepository {
  final _storage = const FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  Future<void> setToken(String key, String token) async =>
      await _storage.write(key: key, value: token);

  @override
  Future<String?> getToken(String key) async =>
      await _storage.read(key: key);

  @override
  Future<void> deleteToken(String key) async =>
      await _storage.delete(key: key);
}