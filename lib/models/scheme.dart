enum SchemeType {
  central,
  state,
}

class Scheme {
  final String id;
  final String schemeName;
  final SchemeType schemeType;
  final String state; // State name for state schemes; empty for central.
  final String basicInfo;
  final List<String> benefits;
  final String applicationLink;
  final String lastDate;

  const Scheme({
    required this.id,
    required this.schemeName,
    required this.schemeType,
    required this.state,
    required this.basicInfo,
    required this.benefits,
    required this.applicationLink,
    required this.lastDate,
  });

  static SchemeType parseSchemeType(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('central')) return SchemeType.central;
    if (lower.contains('state')) return SchemeType.state;
    // Fallback: treat unknown as state.
    return SchemeType.state;
  }

  factory Scheme.fromJson(Map<String, dynamic> json) {
    final rawType = (json['scheme_type'] ?? '').toString();
    final rawId = (json['id'] ?? json['_id'] ?? '').toString();
    final basic = (json['basic_info'] ?? json['description'] ?? '').toString();
    return Scheme(
      id: rawId.isNotEmpty ? rawId : (json['scheme_name'] ?? '').toString(),
      schemeName: (json['scheme_name'] ?? '').toString(),
      schemeType: parseSchemeType(rawType),
      state: (json['state'] ?? '').toString(),
      basicInfo: basic,
      benefits: (json['benefits'] as List? ?? const []).map((e) => e.toString()).toList(),
      applicationLink: (json['application_link'] ?? '').toString(),
      lastDate: (json['last_date'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'scheme_name': schemeName,
        'scheme_type': schemeType == SchemeType.central ? 'Central' : 'State',
        'state': state,
        'basic_info': basicInfo,
        'benefits': benefits,
        'application_link': applicationLink,
        'last_date': lastDate,
      };

  /// For [SchemeType.state] rows: matches [farmerState] (case-insensitive).
  /// Schemes with state `"All"` match every farmer. If [farmerState] is empty,
  /// nothing is filtered out (show all state schemes).
  bool matchesFarmerState(String farmerState) {
    if (schemeType != SchemeType.state) return true;
    final schemeState = state.trim().toLowerCase();
    if (schemeState == 'all') return true;
    final farmer = farmerState.trim().toLowerCase();
    if (farmer.isEmpty) return true;
    if (schemeState.isEmpty) return false;
    return schemeState == farmer;
  }
}

