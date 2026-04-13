import 'dart:convert';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:http/http.dart' as http;

import '../models/auth_role.dart';
import '../models/scheme.dart';
import '../models/user_profile.dart';
import 'local_user_storage.dart';

/// Base URL for KrishiMitra REST API (Express on port 5000).
///
/// Replaces loading `lib/data/schemes.json` from the asset bundle: the app
/// should call `GET …/schemes` instead, e.g. on **Android emulator**:
/// `http.get(Uri.parse('http://10.0.2.2:5000/api/schemes'))` — `10.0.2.2` is
/// the host loopback from the emulator. On **web / desktop / iOS simulator**
/// use `http://localhost:5000/api` (see [fetchSchemes]).
String resolveApiBaseUrl() {
  if (kIsWeb) return 'http://localhost:5000/api';
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:5000/api';
  }
  return 'http://localhost:5000/api';
}

class ApiException implements Exception {
  ApiException(this.message, [this.statusCode]);
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class AuthResponse {
  const AuthResponse({
    required this.token,
    required this.userId,
    required this.userJson,
  });

  final String token;
  final String userId;
  final Map<String, dynamic> userJson;
}

class ApiService {
  ApiService(
    this._storage, {
    String? baseUrl,
    http.Client? httpClient,
  })  : _base = baseUrl ?? resolveApiBaseUrl(),
        _client = httpClient ?? http.Client();

  final LocalUserStorage _storage;
  final String _base;
  final http.Client _client;

  Uri _uri(String path) => Uri.parse('$_base$path');

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (auth) {
      final token = await _storage.readJwtToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  void _throwIfError(http.Response r) {
    if (r.statusCode >= 200 && r.statusCode < 300) return;
    String msg = 'Request failed (${r.statusCode})';
    try {
      final body = jsonDecode(r.body);
      if (body is Map && body['message'] != null) {
        msg = body['message'].toString();
      }
    } catch (_) {
      if (r.body.isNotEmpty) msg = r.body;
    }
    throw ApiException(msg, r.statusCode);
  }

  Future<AuthResponse> register(UserAuthData data) async {
    final profile = data.profile;
    final res = await _client.post(
      _uri('/auth/register'),
      headers: await _headers(),
      body: jsonEncode({
        'name': profile.name,
        'mobile': profile.mobileNumber,
        'password': data.password,
        'state': profile.state,
        'language': profile.language,
        'cropTypes': profile.cropTypes,
        'soilType': profile.soilType,
        'acres': profile.numberOfAcres,
      }),
    );
    _throwIfError(res);
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final token = map['token'] as String? ?? '';
    final user = map['user'] as Map<String, dynamic>? ?? {};
    final userId = user['id']?.toString() ?? '';
    if (token.isEmpty || userId.isEmpty) {
      throw ApiException('Invalid register response');
    }
    return AuthResponse(token: token, userId: userId, userJson: user);
  }

  Future<AuthResponse> login({
    required String mobile,
    required String password,
  }) async {
    final res = await _client.post(
      _uri('/auth/login'),
      headers: await _headers(),
      body: jsonEncode({
        'mobile': mobile,
        'password': password,
      }),
    );
    _throwIfError(res);
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final token = map['token'] as String? ?? '';
    final user = map['user'] as Map<String, dynamic>? ?? {};
    final userId = user['id']?.toString() ?? '';
    if (token.isEmpty || userId.isEmpty) {
      throw ApiException('Invalid login response');
    }
    return AuthResponse(token: token, userId: userId, userJson: user);
  }

  Future<AuthResponse> adminLogin({
    required String mobile,
    required String password,
  }) async {
    final res = await _client.post(
      _uri('/auth/admin-login'),
      headers: await _headers(),
      body: jsonEncode({
        'mobile': mobile,
        'password': password,
      }),
    );
    _throwIfError(res);
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final token = map['token'] as String? ?? '';
    final user = map['user'] as Map<String, dynamic>? ?? {};
    final userId = user['id']?.toString() ?? '';
    if (token.isEmpty || userId.isEmpty) {
      throw ApiException('Invalid admin login response');
    }
    return AuthResponse(token: token, userId: userId, userJson: user);
  }

  /// `GET /schemes` — same as `http.get(Uri.parse('http://10.0.2.2:5000/api/schemes'))`
  /// on Android; uses [resolveApiBaseUrl] so other platforms hit `localhost`.
  Future<List<Scheme>> fetchSchemes() async {
    final res = await _client.get(
      _uri('/schemes'),
      headers: await _headers(),
    );
    _throwIfError(res);
    final decoded = jsonDecode(res.body);
    if (decoded is! List) {
      throw ApiException('Invalid schemes payload');
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Scheme.fromJson)
        .toList(growable: false);
  }

  /// Toggles bookmark on the server for the authenticated user.
  Future<void> bookmarkScheme(String schemeId) async {
    final res = await _client.post(
      _uri('/bookmark'),
      headers: await _headers(auth: true),
      body: jsonEncode({'schemeId': schemeId}),
    );
    _throwIfError(res);
  }

  Future<Set<String>> fetchBookmarkSchemeIds(String userId) async {
    final res = await _client.get(
      _uri('/bookmark/$userId'),
      headers: await _headers(auth: true),
    );
    _throwIfError(res);
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final list = map['schemeIds'] as List? ?? const [];
    return list.map((e) => e.toString()).toSet();
  }

  Future<void> sendFeedback(String message) async {
    final res = await _client.post(
      _uri('/feedback'),
      headers: await _headers(auth: true),
      body: jsonEncode({'message': message}),
    );
    _throwIfError(res);
  }

  Future<List<Map<String, dynamic>>> fetchFeedbackList() async {
    final res = await _client.get(
      _uri('/feedback'),
      headers: await _headers(auth: true),
    );
    _throwIfError(res);
    final decoded = jsonDecode(res.body);
    if (decoded is! List) {
      throw ApiException('Invalid feedback payload');
    }
    return decoded.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  void close() => _client.close();
}

UserProfile userProfileFromApiUser(Map<String, dynamic> u) {
  return UserProfile(
    mobileNumber: (u['mobile'] ?? '').toString(),
    name: (u['name'] ?? '').toString(),
    state: (u['state'] ?? '').toString(),
    language: (u['language'] ?? '').toString(),
    cropTypes: (u['cropTypes'] as List? ?? const [])
        .map((e) => e.toString())
        .toList(),
    soilType: (u['soilType'] ?? '').toString(),
    numberOfAcres: int.tryParse((u['acres'] ?? 0).toString()) ?? 0,
  );
}

AuthRole authRoleFromApiUser(Map<String, dynamic> u) {
  final r = (u['role'] ?? 'user').toString().toLowerCase();
  return r == 'admin' ? AuthRole.admin : AuthRole.user;
}
