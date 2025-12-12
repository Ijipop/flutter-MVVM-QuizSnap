import 'dart:math' as math;

// Modèle pour les statistiques détaillées de l'utilisateur
class UserStatsModel {
  final int totalQuizzes;
  final int totalCorrectAnswers;
  final int totalQuestions;
  final Map<String, int> categoryScores;
  final Map<String, int> categoryLevels; // Niveau par catégorie
  final Map<String, bool> unlockedCategories; // Catégories débloquées
  final int totalScore; // Score total avec bonus
  final int bestStreak; // Meilleur streak
  final int currentStreak; // Streak actuel
  final List<String> badges; // Badges obtenus
  final DateTime? lastDailyChallenge; // Dernier défi quotidien
  final Map<String, int> powerUpsUsed; // Power-ups utilisés
  final Map<String, dynamic> performanceData; // Données de performance

  UserStatsModel({
    required this.totalQuizzes,
    required this.totalCorrectAnswers,
    required this.totalQuestions,
    Map<String, int>? categoryScores,
    Map<String, int>? categoryLevels,
    Map<String, bool>? unlockedCategories,
    int? totalScore,
    int? bestStreak,
    int? currentStreak,
    List<String>? badges,
    this.lastDailyChallenge,
    Map<String, int>? powerUpsUsed,
    Map<String, dynamic>? performanceData,
  })  : categoryScores = categoryScores ?? {},
        categoryLevels = categoryLevels ?? {},
        unlockedCategories = unlockedCategories ?? {},
        totalScore = totalScore ?? 0,
        bestStreak = bestStreak ?? 0,
        currentStreak = currentStreak ?? 0,
        badges = badges ?? [],
        powerUpsUsed = powerUpsUsed ?? {},
        performanceData = performanceData ?? {};

  // Taux de réussite global
  double get overallAccuracy {
    if (totalQuestions == 0) return 0.0;
    return (totalCorrectAnswers / totalQuestions) * 100;
  }

  // Taux de réussite par catégorie
  double getCategoryAccuracy(String category) {
    final categoryScore = categoryScores[category] ?? 0;
    // On suppose qu'on peut calculer le total de questions par catégorie
    // depuis performanceData ou un autre champ
    return 0.0; // À implémenter selon les besoins
  }

  // Obtenir le niveau d'une catégorie
  int getCategoryLevel(String category) {
    return categoryLevels[category] ?? 1;
  }

  // Vérifier si une catégorie est débloquée
  bool isCategoryUnlocked(String category) {
    return unlockedCategories[category] ?? true; // Par défaut débloqué
  }

  // Calculer le niveau basé sur le score
  int calculateLevel(int score) {
    // Niveau = racine carrée du score / 10 (arrondi)
    return ((score / 10).sqrt()).round().clamp(1, 100);
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'total_quizzes': totalQuizzes,
      'total_correct_answers': totalCorrectAnswers,
      'total_questions': totalQuestions,
      'category_scores': categoryScores,
      'category_levels': categoryLevels,
      'unlocked_categories': unlockedCategories,
      'total_score': totalScore,
      'best_streak': bestStreak,
      'current_streak': currentStreak,
      'badges': badges,
      'last_daily_challenge': lastDailyChallenge?.toIso8601String(),
      'power_ups_used': powerUpsUsed,
      'performance_data': performanceData,
    };
  }

  // Factory depuis JSON
  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      totalQuizzes: json['total_quizzes'] ?? 0,
      totalCorrectAnswers: json['total_correct_answers'] ?? 0,
      totalQuestions: json['total_questions'] ?? 0,
      categoryScores: Map<String, int>.from(json['category_scores'] ?? {}),
      categoryLevels: Map<String, int>.from(json['category_levels'] ?? {}),
      unlockedCategories: Map<String, bool>.from(
          json['unlocked_categories'] ?? {}),
      totalScore: json['total_score'] ?? 0,
      bestStreak: json['best_streak'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
      lastDailyChallenge: json['last_daily_challenge'] != null
          ? DateTime.parse(json['last_daily_challenge'])
          : null,
      powerUpsUsed: Map<String, int>.from(json['power_ups_used'] ?? {}),
      performanceData: Map<String, dynamic>.from(
          json['performance_data'] ?? {}),
    );
  }

  // Créer une copie avec des valeurs mises à jour
  UserStatsModel copyWith({
    int? totalQuizzes,
    int? totalCorrectAnswers,
    int? totalQuestions,
    Map<String, int>? categoryScores,
    Map<String, int>? categoryLevels,
    Map<String, bool>? unlockedCategories,
    int? totalScore,
    int? bestStreak,
    int? currentStreak,
    List<String>? badges,
    DateTime? lastDailyChallenge,
    Map<String, int>? powerUpsUsed,
    Map<String, dynamic>? performanceData,
  }) {
    return UserStatsModel(
      totalQuizzes: totalQuizzes ?? this.totalQuizzes,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      categoryScores: categoryScores ?? this.categoryScores,
      categoryLevels: categoryLevels ?? this.categoryLevels,
      unlockedCategories: unlockedCategories ?? this.unlockedCategories,
      totalScore: totalScore ?? this.totalScore,
      bestStreak: bestStreak ?? this.bestStreak,
      currentStreak: currentStreak ?? this.currentStreak,
      badges: badges ?? this.badges,
      lastDailyChallenge: lastDailyChallenge ?? this.lastDailyChallenge,
      powerUpsUsed: powerUpsUsed ?? this.powerUpsUsed,
      performanceData: performanceData ?? this.performanceData,
    );
  }
}

// Extension pour calculer la racine carrée
extension MathExtension on num {
  double sqrt() {
    return math.sqrt(this);
  }
}

