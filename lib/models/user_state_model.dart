class UserState {
  final String userId;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  UserState({
    required this.userId,
    required this.isUnlocked,
    this.unlockedAt,
  });

  factory UserState.fromJson(Map<String, dynamic> json) => UserState(
        userId: json['userId'] ?? '',
        isUnlocked: json['isUnlocked'] ?? false,
        unlockedAt: json['unlockedAt'] != null
            ? DateTime.parse(json['unlockedAt'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'isUnlocked': isUnlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  UserState copyWith({
    String? userId,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) => UserState(
        userId: userId ?? this.userId,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );
}

