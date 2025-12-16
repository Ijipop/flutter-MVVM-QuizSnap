
enum QuestionType {
  multipleChoice, // Choix multiples
  trueFalse,      // Vrai ou Faux
  shortAnswer,    // Réponse courte
  image,          // Question avec image
}


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
  final String? imageUrl;
  final QuestionType type;

  QuestionModel({
    required this.id,
    required this.category,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.difficulty,
    this.imageUrl,
    QuestionType? type,
  })  : correctAnswer = options.isNotEmpty && correctIndex < options.length
            ? options[correctIndex]
            : '',
        type = type ?? QuestionType.multipleChoice;

  // Factory pour créer depuis JSON
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final questionType = _parseQuestionType(json['type'] ?? 'multiple_choice');
    final options = List<String>.from(json['options'] ?? []);
    
    return QuestionModel(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      question: json['question'] ?? '',
      options: options,
      correctIndex: json['correct_index'] ?? 0,
      explanation: json['explanation'] ?? '',
      difficulty: json['difficulty'] ?? 'medium',
      imageUrl: json['image_url'],
      type: questionType,
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
      'image_url': imageUrl,
      'type': _questionTypeToString(type),
    };
  }

  // Parser pour le type de question
  static QuestionType _parseQuestionType(String type) {
    switch (type.toLowerCase()) {
      case 'true_false':
      case 'truefalse':
        return QuestionType.trueFalse;
      case 'short_answer':
      case 'shortanswer':
        return QuestionType.shortAnswer;
      case 'image':
        return QuestionType.image;
      default:
        return QuestionType.multipleChoice;
    }
  }

  // Convertir le type en string
  static String _questionTypeToString(QuestionType type) {
    switch (type) {
      case QuestionType.trueFalse:
        return 'true_false';
      case QuestionType.shortAnswer:
        return 'short_answer';
      case QuestionType.image:
        return 'image';
      default:
        return 'multiple_choice';
    }
  }

  // Vérifier si la réponse est correcte
  bool isCorrect(String answer) {
    if (type == QuestionType.shortAnswer) {
      // Pour les réponses courtes, comparaison insensible à la casse
      return answer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
    }
    return answer == correctAnswer;
  }

  // Vérifier si la réponse est correcte par index
  bool isCorrectIndex(int index) {
    return index == correctIndex;
  }
}

