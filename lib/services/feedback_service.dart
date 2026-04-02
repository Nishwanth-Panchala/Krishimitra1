import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/feedback.dart';

class FeedbackService {
  static const String _key = 'krishi_mitra_feedbacks';

  Future<List<FeedbackEntry>> loadFeedback() async {
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
    final prefs = await SharedPreferences.getInstance();
    final existingRawList = prefs.getStringList(_key) ?? const <String>[];
    final list = existingRawList.toList();
    list.add(jsonEncode(entry.toJson()));
    await prefs.setStringList(_key, list);
  }
}

