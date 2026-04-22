import '../models/scheme.dart';
import '../services/api_service.dart';
import 'schemes_local_data_source.dart';
import 'schemes_admin_store.dart';

/// Loads schemes from backend + local JSON fallback,
/// merges both, removes duplicates, and supports admin overrides.
class SchemesRepository {
  SchemesRepository(
    this._localSource, {
    required SchemesAdminStore adminStore,
    required ApiService apiService,
  })  : _adminStore = adminStore,
        _api = apiService;

  final SchemesLocalDataSource _localSource;
  final SchemesAdminStore _adminStore;
  final ApiService _api;

  /// 🔥 MAIN FIX: Merge remote + local + remove duplicates
  Future<List<Scheme>> fetchSchemes() async {
    try {
      final remote = await _api.fetchSchemes();
      final local = await _localSource.loadSchemes();

      // 🔥 Merge both sources
      final combined = [...remote, ...local];

      // 🔥 Remove duplicates using scheme_name
      final uniqueMap = <String, Scheme>{};

      for (final scheme in combined) {
        final key = scheme.schemeName.trim().toLowerCase();
        uniqueMap[key] = scheme; // overwrite duplicates safely
      }

      return uniqueMap.values.toList();
    } catch (e) {
      // fallback to local if API fails
      return _localSource.loadSchemes();
    }
  }

  /// Filter schemes by type (Central / State)
  List<Scheme> filterByType(List<Scheme> schemes, SchemeType type) {
    return schemes
        .where((s) => s.schemeType == type)
        .toList(growable: false);
  }

  /// Admin override (stored schemes take priority)
  Future<List<Scheme>> fetchSchemesWithAdminOverrides() async {
    final hasStored = await _adminStore.hasStoredSchemes();

    if (hasStored) {
      return _adminStore.readStoredSchemes();
    }

    return fetchSchemes();
  }

  /// Save admin-updated schemes
  Future<void> saveAllSchemes(List<Scheme> schemes) {
    return _adminStore.writeStoredSchemes(schemes);
  }
}