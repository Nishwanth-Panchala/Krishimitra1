import '../models/scheme.dart';
import 'schemes_local_data_source.dart';
import 'schemes_admin_store.dart';

class SchemesRepository {
  SchemesRepository(
    this._localSource, {
    required SchemesAdminStore adminStore,
  }) : _adminStore = adminStore;

  final SchemesLocalDataSource _localSource;
  final SchemesAdminStore _adminStore;

  Future<List<Scheme>> fetchSchemes() => _localSource.loadSchemes();

  List<Scheme> filterByType(List<Scheme> schemes, SchemeType type) {
    return schemes.where((s) => s.schemeType == type).toList(growable: false);
  }

  Future<List<Scheme>> fetchSchemesWithAdminOverrides() async {
    final hasStored = await _adminStore.hasStoredSchemes();
    if (!hasStored) return _localSource.loadSchemes();
    return _adminStore.readStoredSchemes();
  }

  Future<void> saveAllSchemes(List<Scheme> schemes) {
    return _adminStore.writeStoredSchemes(schemes);
  }
}

