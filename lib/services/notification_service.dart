import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_notification.dart';

class NotificationService {
  static const String _key = 'krishi_mitra_notifications';
  static const String _readKey = 'krishi_mitra_notification_reads';

  Future<List<AppNotificationEntry>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(AppNotificationEntry.fromJson)
        .toList(growable: false);
  }

  Future<void> add(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    final list = <AppNotificationEntry>[];
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        list.addAll(
          decoded
              .whereType<Map<String, dynamic>>()
              .map(AppNotificationEntry.fromJson),
        );
      }
    }

    final entry = AppNotificationEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      message: trimmed,
      createdAt: DateTime.now(),
    );
    list.add(entry);

    await prefs.setString(
      _key,
      jsonEncode(list.map((e) => e.toJson()).toList(growable: false)),
    );
  }

  Future<Set<String>> loadReadIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_readKey) ?? const <String>[];
    return list.toSet();
  }

  Future<void> markAsRead(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final currentRaw = prefs.getStringList(_readKey) ?? const <String>[];
    final next = {...currentRaw, ...ids};
    await prefs.setStringList(_readKey, next.toList());
  }
}

