import '../models/auth_role.dart';
import '../models/user_profile.dart';
import 'api_service.dart';
import 'local_user_storage.dart';

class LocalAuthService {
  LocalAuthService(this._api, this._storage);

  final ApiService _api;
  final LocalUserStorage _storage;

  static const String adminMobile = 'admin';
  static const String adminPassword = 'admin123';

  UserAuthData _normalizeAuth(UserAuthData data) {
    final mobile = data.mobileNumber.trim();
    final password = data.password.trim();
    final p = data.profile;
    final profile = UserProfile(
      mobileNumber: mobile,
      name: p.name.trim(),
      state: p.state,
      language: p.language,
      cropTypes: p.cropTypes,
      soilType: p.soilType,
      numberOfAcres: p.numberOfAcres,
    );
    return UserAuthData(
      mobileNumber: mobile,
      password: password,
      profile: profile,
    );
  }

  Future<void> registerUser(UserAuthData data) async {
    final normalized = _normalizeAuth(data);
    try {
      final res = await _api.register(normalized);
      await _storage.saveSession(token: res.token, userId: res.userId);
      final profile = userProfileFromApiUser(res.userJson);
      final role = authRoleFromApiUser(res.userJson);
      await _storage.saveUserAuth(
        UserAuthData(
          mobileNumber: profile.mobileNumber.trim(),
          password: normalized.password,
          profile: profile,
        ),
      );
      await _storage.saveRole(role);
    } catch (_) {
      await _storage.saveUserAuth(normalized);
    }
  }

  /// Returns user profile if credentials match; throws otherwise.
  Future<UserProfile> loginUser({
    required String mobileNumber,
    required String password,
  }) async {
    final mobile = mobileNumber.trim();
    final pwd = password.trim();
    try {
      final res = await _api.login(mobile: mobile, password: pwd);
      await _storage.saveSession(token: res.token, userId: res.userId);
      final profile = userProfileFromApiUser(res.userJson);
      await _storage.saveUserAuth(
        UserAuthData(
          mobileNumber: profile.mobileNumber.trim(),
          password: pwd,
          profile: profile,
        ),
      );
      await _storage.saveRole(authRoleFromApiUser(res.userJson));
      return profile;
    } catch (_) {
      final userAuth = await _storage.readUserAuth();
      if (userAuth == null) {
        throw const AuthException(
          'No saved account on this device. Register again with the backend running, '
          'and in Atlas open your app database (e.g. krishimitra) → users — not sample_mflix.',
        );
      }

      if (userAuth.mobileNumber.trim() != mobile ||
          userAuth.password.trim() != pwd) {
        throw const AuthException('Invalid mobile number or password.');
      }

      await _storage.clearSession();
      await _storage.saveRole(AuthRole.user);
      return userAuth.profile;
    }
  }

  bool isAdminLogin({
    required String mobileNumber,
    required String password,
  }) {
    return mobileNumber == adminMobile && password == adminPassword;
  }

  Future<void> loginAdmin() async {
    await _storage.saveRole(AuthRole.admin);
  }

  /// Server admin login when available; otherwise local demo credentials.
  Future<void> loginAdminWithCredentials({
    required String mobileNumber,
    required String password,
  }) async {
    final mobile = mobileNumber.trim();
    final pwd = password.trim();
    try {
      final res = await _api.adminLogin(mobile: mobile, password: pwd);
      await _storage.saveSession(token: res.token, userId: res.userId);
      final profile = userProfileFromApiUser(res.userJson);
      await _storage.saveUserAuth(
        UserAuthData(
          mobileNumber: profile.mobileNumber.trim(),
          password: pwd,
          profile: profile,
        ),
      );
      await _storage.saveRole(AuthRole.admin);
    } catch (_) {
      if (!isAdminLogin(mobileNumber: mobile, password: pwd)) {
        throw const AuthException('Invalid admin credentials.');
      }
      await _storage.clearSession();
      await loginAdmin();
    }
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
