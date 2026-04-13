import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'local_user_storage.dart';

class BookmarkService {
  BookmarkService({
    ApiService? api,
    LocalUserStorage? storage,
  })  : _api = api,
        _storage = storage;

  static const String _key = 'krishi_mitra_bookmarks';

  final ApiService? _api;
  final LocalUserStorage? _storage;

  Future<Set<String>> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? const <String>[];
    final local = list.toSet();

    try {
      final api = _api;
      final storage = _storage;
      if (api != null && storage != null) {
        final token = await storage.readJwtToken();
        final userId = await storage.readBackendUserId();
        if (token != null && userId != null) {
          final remote = await api.fetchBookmarkSchemeIds(userId);
          await saveBookmarks(remote);
          return remote;
        }
      }
    } catch (_) {}

    return local;
  }

  Future<void> saveBookmarks(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids.toList());
  }
}
