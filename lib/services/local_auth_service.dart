import '../models/user_profile.dart';
import '../models/auth_role.dart';
import 'local_user_storage.dart';

class LocalAuthService {
  LocalAuthService(this._storage);

  final LocalUserStorage _storage;

  static const String adminMobile = 'admin';
  static const String adminPassword = 'admin123';

  Future<void> registerUser(UserAuthData data) => _storage.saveUserAuth(data);

  /// Returns user profile if credentials match; throws otherwise.
  Future<UserProfile> loginUser({
    required String mobileNumber,
    required String password,
  }) async {
    final userAuth = await _storage.readUserAuth();
    if (userAuth == null) {
      throw const AuthException('No registered user found. Please register first.');
    }

    if (userAuth.mobileNumber != mobileNumber || userAuth.password != password) {
      throw const AuthException('Invalid mobile number or password.');
    }

    // Persist role for UI differences (mock-only).
    await _storage.saveRole(AuthRole.user);
    return userAuth.profile;
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
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

