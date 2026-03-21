import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/app_user.dart';

class SessionService {
  SessionService._();

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  static Future<void> saveSession({
    required String token,
    required AppUser user,
  }) async {
    await Future.wait([
      _storage.write(key: _tokenKey, value: token),
      _storage.write(key: _userKey, value: jsonEncode(user.toJson())),
    ]);
  }

  static Future<String?> readToken() {
    return _storage.read(key: _tokenKey);
  }

  static Future<AppUser?> readUser() async {
    final value = await _storage.read(key: _userKey);
    if (value == null || value.isEmpty) {
      return null;
    }

    return AppUser.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  static Future<bool> hasSession() async {
    final token = await readToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _userKey),
    ]);
  }
}
