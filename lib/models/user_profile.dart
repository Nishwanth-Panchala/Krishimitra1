class UserProfile {
  final String mobileNumber;
  final String name;
  final String state;
  final String language;
  final List<String> cropTypes;
  final String soilType; // Black / Red
  final int numberOfAcres;

  const UserProfile({
    required this.mobileNumber,
    required this.name,
    required this.state,
    required this.language,
    required this.cropTypes,
    required this.soilType,
    required this.numberOfAcres,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      mobileNumber: (json['mobileNumber'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      language: (json['language'] ?? '').toString(),
      cropTypes: (json['cropTypes'] as List? ?? const []).map((e) => e.toString()).toList(),
      soilType: (json['soilType'] ?? '').toString(),
      numberOfAcres: int.tryParse((json['numberOfAcres'] ?? '0').toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'mobileNumber': mobileNumber,
        'name': name,
        'state': state,
        'language': language,
        'cropTypes': cropTypes,
        'soilType': soilType,
        'numberOfAcres': numberOfAcres,
      };
}

class UserAuthData {
  final String mobileNumber;
  final String password;
  final UserProfile profile;

  const UserAuthData({
    required this.mobileNumber,
    required this.password,
    required this.profile,
  });

  factory UserAuthData.fromJson(Map<String, dynamic> json) {
    return UserAuthData(
      mobileNumber: (json['mobileNumber'] ?? '').toString(),
      password: (json['password'] ?? '').toString(),
      profile: UserProfile.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() => {
        'mobileNumber': mobileNumber,
        'password': password,
        ...profile.toJson(),
      };
}

