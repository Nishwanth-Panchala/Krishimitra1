enum AuthRole {
  user,
  admin;

  static AuthRole? fromString(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'admin':
        return AuthRole.admin;
      case 'user':
        return AuthRole.user;
      default:
        return null;
    }
  }

  String toShortString() => switch (this) {
        AuthRole.admin => 'admin',
        AuthRole.user => 'user',
      };
}

