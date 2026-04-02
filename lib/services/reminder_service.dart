import 'package:shared_preferences/shared_preferences.dart';

class ReminderService {
  static const String _key = 'krishi_mitra_reminders';

  Future<Set<String>> loadReminderIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? const <String>[];
    return list.toSet();
  }

  Future<void> saveReminderIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids.toList());
  }
}

