class Tense {
  final String id;
  final String name;
  final String description;
  final String emoji;

  Tense({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
  });

  factory Tense.fromJson(Map<String, dynamic> json) {
    return Tense(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      emoji: json['emoji'] ?? '📖',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'description': description,
        'emoji': emoji,
      };
}

