class FeedbackEntry {
  final String mobileNumber;
  final String message;
  final DateTime createdAt;

  const FeedbackEntry({
    required this.mobileNumber,
    required this.message,
    required this.createdAt,
  });

  factory FeedbackEntry.fromJson(Map<String, dynamic> json) {
    return FeedbackEntry(
      mobileNumber: (json['mobileNumber'] ?? json['mobile'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      createdAt: DateTime.tryParse(
            (json['createdAt'] ?? json['created_at'] ?? '').toString(),
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'mobileNumber': mobileNumber,
        'message': message,
        'createdAt': createdAt.toIso8601String(),
      };
}

