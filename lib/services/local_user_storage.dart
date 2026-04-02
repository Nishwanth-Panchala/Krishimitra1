import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import '../models/auth_role.dart';

class LocalUserStorage {
  static const String _key = 'krishi_mitra_user_auth';
  static const String _roleKey = 'krishi_mitra_role';

  Future<void> saveUserAuth(UserAuthData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data.toJson()));
  }

  Future<UserAuthData?> readUserAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return UserAuthData.fromJson(decoded);
    }
    return null;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await prefs.remove(_roleKey);
  }

  Future<void> saveRole(AuthRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role.toShortString());
  }

  Future<AuthRole?> readRole() async {
    final prefs = await SharedPreferences.getInstance();
    return AuthRole.fromString(prefs.getString(_roleKey));
  }

  /// Updates the saved profile while preserving the existing password.
  /// This is a local/mock-only implementation for the current stage.
  Future<void> updateProfile(UserProfile profile) async {
    final existing = await readUserAuth();
    if (existing == null) {
      // If no user exists yet, just save what we were given.
      await saveUserAuth(
        UserAuthData(
          mobileNumber: profile.mobileNumber,
          password: '',
          profile: profile,
        ),
      );
      return;
    }

    await saveUserAuth(
      UserAuthData(
        mobileNumber: profile.mobileNumber,
        password: existing.password,
        profile: profile,
      ),
    );
  }
}

