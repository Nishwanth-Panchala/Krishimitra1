import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const String _key = 'krishi_mitra_bookmarks';

  Future<Set<String>> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? const <String>[];
    return list.toSet();
  }

  Future<void> saveBookmarks(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids.toList());
  }
}

