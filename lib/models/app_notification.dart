class AppNotificationEntry {
  final String id;
  final String message;
  final DateTime createdAt;

  const AppNotificationEntry({
    required this.id,
    required this.message,
    required this.createdAt,
  });

  factory AppNotificationEntry.fromJson(Map<String, dynamic> json) {
    return AppNotificationEntry(
      id: (json['id'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'message': message,
        'createdAt': createdAt.toIso8601String(),
      };
}

