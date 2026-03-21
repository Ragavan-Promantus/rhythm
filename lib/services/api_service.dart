import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/app_user.dart';
import '../models/auth_result.dart';
import '../models/song.dart';
import 'session_service.dart';

class ApiService {
  ApiService._();

  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:5000';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:5000';
      default:
        return 'http://localhost:5000';
    }
  }

  static Uri _uri(String path) => Uri.parse('$baseUrl$path');

  static String streamUrl(String songId) => '$baseUrl/songs/$songId/stream';

  static String downloadUrl(String songId) => '$baseUrl/songs/$songId/download';

  static Future<Map<String, String>> _headers({
    bool includeAuth = false,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await SessionService.readToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Future<AuthResult> login({
    required String identifier,
    required String password,
  }) async {
    final response = await http.post(
      _uri('/auth/login'),
      headers: await _headers(),
      body: jsonEncode({'identifier': identifier, 'password': password}),
    );

    log('Login response: ${response.statusCode} ${response.body}');

    return _parseAuthResponse(response);
  }

  static Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      _uri('/auth/register'),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'fullName': name,
        'email': email,
        'password': password,
      }),
    );

    return _parseAuthResponse(response);
  }

  static Future<List<Song>> fetchSongs() async {
    final response = await http.get(
      _uri('/songs'),
      headers: await _headers(includeAuth: true),
    );

    final data = _parseResponseBody(response);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _extractMessage(data, fallback: 'Unable to load songs.'),
      );
    }

    final rawSongs = switch (data) {
      List<dynamic> value => value,
      Map<String, dynamic> value =>
        (value['songs'] as List<dynamic>?) ??
            (value['data'] as List<dynamic>?) ??
            const [],
      _ => const [],
    };

    return rawSongs
        .whereType<Map<String, dynamic>>()
        .map(Song.fromJson)
        .where((song) => song.id.isNotEmpty)
        .toList();
  }

  static AuthResult _parseAuthResponse(http.Response response) {
    final data = _parseResponseBody(response);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _extractMessage(data, fallback: 'Authentication request failed.'),
      );
    }

    if (data is! Map<String, dynamic>) {
      throw const ApiException('Unexpected response format from the server.');
    }

    final token = '${data['token'] ?? data['accessToken'] ?? ''}';
    final userJson =
        (data['user'] as Map<String, dynamic>?) ??
        (data['profile'] as Map<String, dynamic>?) ??
        (data['data'] as Map<String, dynamic>?);

    if (token.isEmpty || userJson == null) {
      throw const ApiException(
        'Token or user profile is missing in the response.',
      );
    }

    return AuthResult(token: token, user: AppUser.fromJson(userJson));
  }

  static dynamic _parseResponseBody(http.Response response) {
    if (response.body.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return null;
    }
  }

  static String _extractMessage(dynamic data, {required String fallback}) {
    if (data is Map<String, dynamic>) {
      final value = data['message'] ?? data['error'] ?? data['detail'];
      if (value != null && '$value'.trim().isNotEmpty) {
        return '$value';
      }
    }

    return fallback;
  }
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
