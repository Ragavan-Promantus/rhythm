import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/app_user.dart';
import '../models/auth_result.dart';
import '../models/song.dart';
import 'session_service.dart';

class ApiService {
  ApiService._();

  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.37:5000',
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

    return _parseAuthResponse(response);
  }

  static Future<String> register({
    required String username,
    required String email,
    required String password,
    required String mobile,
    List<int> profileImage = const [],
    String? profileImageFilename,
  }) async {
    final payloadLog = {
      'username': username,
      'email': email,
      'password': password,
      'mobile': mobile,
      'profile_image_bytes': profileImage.length,
      'profile_image_filename': profileImageFilename ?? '',
    };

    debugPrint('Register payload: ${jsonEncode(payloadLog)}');

    final request = http.MultipartRequest('POST', _uri('/auth/register'));
    final headers = await _headers();
    request.headers.addAll(headers..remove('Content-Type'));
    request.fields.addAll({
      'username': username,
      'email': email,
      'password': password,
      'mobile': mobile,
    });

    if (profileImage.isNotEmpty) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'profile_image',
          profileImage,
          filename: profileImageFilename ?? 'profile.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final data = _parseResponseBody(response);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _extractMessage(data, fallback: 'Registration request failed.'),
      );
    }

    return _extractMessage(data, fallback: 'User registered successfully');
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
