
// Modèle pour une question de quiz
class QuestionModel {
  final String id;
  final String category;
  final String question;
  final List<String> options;
  final int correctIndex; 
  final String correctAnswer; 
  final String explanation;
  final String difficulty;

  QuestionModel({
    required this.id,
    required this.category,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.difficulty,
  })  : correctAnswer = options.isNotEmpty && correctIndex < options.length
            ? options[correctIndex]
            : '';

  // Factory pour créer depuis JSON
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final options = List<String>.from(json['options'] ?? []);
    
    return QuestionModel(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      question: json['question'] ?? '',
      options: options,
      correctIndex: json['correct_index'] ?? 0,
      explanation: json['explanation'] ?? '',
      difficulty: json['difficulty'] ?? 'medium',
    );
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'question': question,
      'options': options,
      'correct_index': correctIndex,
      'explanation': explanation,
      'difficulty': difficulty,
    };
  }

  // Vérifier si la réponse est correcte
  bool isCorrect(String answer) {
    return answer == correctAnswer;
  }
}

