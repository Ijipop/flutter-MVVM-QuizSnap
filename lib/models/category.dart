// Modèle pour une catégorie de quiz
class Category {
  final int id;
  final String name;
  final int questionCount;

  Category({
    required this.id,
    required this.name,
    this.questionCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      questionCount: json['questionCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'questionCount': questionCount,
    };
  }
}

