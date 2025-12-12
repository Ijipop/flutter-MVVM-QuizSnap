import 'question_model.dart';

// Enum pour les modes de jeu
enum GameMode {
  quick,      // Mode Rapide (10 questions, 15 sec chacune)
  marathon,  // Mode Marathon (50 questions)
  survival,  // Mode Survie (jusqu'à la première erreur)
  daily,     // Mode Défi Quotidien
  custom,    // Mode personnalisé
}

// Modèle pour une session de quiz
class QuizSessionModel {
  final String id;
  final String category;
  final GameMode gameMode;
  final List<QuestionModel> questions;
  final Map<int, String> userAnswers; // questionIndex -> answer
  final Map<int, int> answerTimes; // questionIndex -> time in seconds
  final DateTime startTime;
  DateTime? endTime;
  final int lives; // Nombre de vies restantes
  final int initialLives;
  final int streak; // Réponses consécutives correctes
  final List<String> usedPowerUps; // Power-ups utilisés

  QuizSessionModel({
    required this.id,
    required this.category,
    required this.gameMode,
    required this.questions,
    Map<int, String>? userAnswers,
    Map<int, int>? answerTimes,
    DateTime? startTime,
    this.endTime,
    int? lives,
    int? initialLives,
    int? streak,
    List<String>? usedPowerUps,
  })  : userAnswers = userAnswers ?? {},
        answerTimes = answerTimes ?? {},
        startTime = startTime ?? DateTime.now(),
        lives = lives ?? 5,
        initialLives = initialLives ?? 5,
        streak = streak ?? 0,
        usedPowerUps = usedPowerUps ?? [];

  // Calculer le score avec bonus
  int calculateScore() {
    int score = 0;
    int currentStreak = 0;

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final userAnswer = userAnswers[i];
      final answerTime = answerTimes[i] ?? 0;

      if (userAnswer != null && question.isCorrect(userAnswer)) {
        // Points de base
        int points = 10;

        // Bonus de rapidité (si répondu en moins de 10 secondes)
        if (answerTime < 10) {
          points += (10 - answerTime).clamp(0, 5);
        }

        // Bonus de streak
        currentStreak++;
        if (currentStreak >= 3) {
          points += (currentStreak - 2) * 2; // +2 points par streak au-delà de 3
        }

        // Bonus selon la difficulté
        switch (question.difficulty) {
          case 'hard':
            points += 5;
            break;
          case 'medium':
            points += 2;
            break;
          default:
            break;
        }

        score += points;
      } else if (userAnswer != null) {
        // Pénalité pour mauvaise réponse
        score -= 2;
        currentStreak = 0;
      }
    }

    return score.clamp(0, double.infinity).toInt();
  }

  // Calculer le nombre de bonnes réponses
  int get correctAnswers {
    int count = 0;
    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final userAnswer = userAnswers[i];
      if (userAnswer != null && question.isCorrect(userAnswer)) {
        count++;
      }
    }
    return count;
  }

  // Vérifier si la session est terminée
  bool get isComplete {
    if (gameMode == GameMode.survival) {
      // En mode survie, terminé si plus de vies
      return lives <= 0 || userAnswers.length >= questions.length;
    }
    // Pour les autres modes, terminé quand toutes les questions sont répondues
    return userAnswers.length >= questions.length;
  }

  // Durée de la session
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'game_mode': _gameModeToString(gameMode),
      'questions': questions.map((q) => q.toJson()).toList(),
      'user_answers': userAnswers.map((k, v) => MapEntry(k.toString(), v)),
      'answer_times': answerTimes.map((k, v) => MapEntry(k.toString(), v)),
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'lives': lives,
      'initial_lives': initialLives,
      'streak': streak,
      'used_power_ups': usedPowerUps,
    };
  }

  // Factory depuis JSON
  factory QuizSessionModel.fromJson(Map<String, dynamic> json) {
    return QuizSessionModel(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      gameMode: _parseGameMode(json['game_mode'] ?? 'custom'),
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => QuestionModel.fromJson(q))
              .toList() ??
          [],
      userAnswers: (json['user_answers'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(int.parse(k), v.toString())) ??
          {},
      answerTimes: (json['answer_times'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(int.parse(k), v as int)) ??
          {},
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : DateTime.now(),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'])
          : null,
      lives: json['lives'] ?? 5,
      initialLives: json['initial_lives'] ?? 5,
      streak: json['streak'] ?? 0,
      usedPowerUps: List<String>.from(json['used_power_ups'] ?? []),
    );
  }

  static GameMode _parseGameMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'quick':
        return GameMode.quick;
      case 'marathon':
        return GameMode.marathon;
      case 'survival':
        return GameMode.survival;
      case 'daily':
        return GameMode.daily;
      default:
        return GameMode.custom;
    }
  }

  static String _gameModeToString(GameMode mode) {
    switch (mode) {
      case GameMode.quick:
        return 'quick';
      case GameMode.marathon:
        return 'marathon';
      case GameMode.survival:
        return 'survival';
      case GameMode.daily:
        return 'daily';
      default:
        return 'custom';
    }
  }
}

