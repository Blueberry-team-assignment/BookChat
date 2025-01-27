import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecureStorage {
  static final storage = FlutterSecureStorage();

  static Future setToken(String token) async =>
      await storage.write(key: 'auth_token', value: token);

  static Future<String?> getToken() async =>
      await storage.read(key: 'auth_token');

  static Future deleteToken() async =>
      await storage.delete(key: 'auth_token');
}