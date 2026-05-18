class Story {
  final String id;
  final String tenseId;
  final String title;
  final String englishText;
  final String hindiText;
  final bool isDemo;
  final String? category;

  Story({
    required this.id,
    required this.tenseId,
    required this.title,
    required this.englishText,
    required this.hindiText,
    required this.isDemo,
    this.category,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    final rawTenseId = json['tenseId'];
    final tenseId = rawTenseId is Map
        ? (rawTenseId['_id']?.toString() ?? '')
        : (rawTenseId?.toString() ?? '');

    return Story(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        tenseId: tenseId,
        title: json['title'] ?? '',
        englishText: json['englishText'] ?? '',
        hindiText: json['hindiText'] ?? '',
        isDemo: json['isDemo'] ?? false,
        category: json['category']?.toString(),
      );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'tenseId': tenseId,
        'title': title,
        'englishText': englishText,
        'hindiText': hindiText,
        'isDemo': isDemo,
        'category': category,
      };
}

