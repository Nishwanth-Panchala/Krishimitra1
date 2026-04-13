import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_role.dart';
import '../models/feedback.dart';
import 'api_service.dart';
import 'local_user_storage.dart';

class FeedbackService {
  FeedbackService({
    ApiService? api,
    LocalUserStorage? storage,
  })  : _api = api,
        _storage = storage;

  static const String _key = 'krishi_mitra_feedbacks';

  final ApiService? _api;
  final LocalUserStorage? _storage;

  Future<List<FeedbackEntry>> loadFeedback() async {
    try {
      final api = _api;
      final storage = _storage;
      if (api != null && storage != null) {
        final role = await storage.readRole();
        final token = await storage.readJwtToken();
        if (role == AuthRole.admin && token != null) {
          final rows = await api.fetchFeedbackList();
          return rows.map(FeedbackEntry.fromJson).toList(growable: false);
        }
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key) ?? const <String>[];
    if (rawList.isEmpty) return const [];

    return rawList
        .map((s) {
          final decoded = jsonDecode(s);
          if (decoded is Map<String, dynamic>) {
            return FeedbackEntry.fromJson(decoded);
          }
          return null;
        })
        .whereType<FeedbackEntry>()
        .toList(growable: false);
  }

  Future<void> addFeedback(FeedbackEntry entry) async {
    try {
      final api = _api;
      final storage = _storage;
      if (api != null && storage != null) {
        final token = await storage.readJwtToken();
        if (token != null) {
          await api.sendFeedback(entry.message);
          return;
        }
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    final existingRawList = prefs.getStringList(_key) ?? const <String>[];
    final list = existingRawList.toList();
    list.add(jsonEncode(entry.toJson()));
    await prefs.setStringList(_key, list);
  }
}
