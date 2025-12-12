import 'package:flutter/foundation.dart';
import '../models/user_stats_model.dart';
import '../models/quiz_result.dart';
import '../services/storage_service.dart';

// Provider pour gérer les statistiques avancées
class StatsProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  UserStatsModel? _userStats;
  bool _isLoading = false;

  // Getters
  UserStatsModel? get userStats => _userStats;
  bool get isLoading => _isLoading;

  // Charger les statistiques
  Future<void> loadStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Charger depuis le stockage
      final statsJson = await _storageService.getUserStats();
      if (statsJson != null) {
        _userStats = UserStatsModel.fromJson(statsJson);
      } else {
        // Créer des stats par défaut
        _userStats = UserStatsModel(
          totalQuizzes: 0,
          totalCorrectAnswers: 0,
          totalQuestions: 0,
        );
      }
    } catch (e) {
      debugPrint('❌ StatsProvider: Erreur lors du chargement: $e');
      _userStats = UserStatsModel(
        totalQuizzes: 0,
        totalCorrectAnswers: 0,
        totalQuestions: 0,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mettre à jour les stats après un quiz
  Future<void> updateStats(QuizResult result, {
    int? score,
    int? streak,
    String? category,
  }) async {
    if (_userStats == null) {
      await loadStats();
    }

    final currentStats = _userStats!;
    final newStreak = streak ?? (result.percentage >= 70 ? currentStats.currentStreak + 1 : 0);

    _userStats = currentStats.copyWith(
      totalQuizzes: currentStats.totalQuizzes + 1,
      totalCorrectAnswers: currentStats.totalCorrectAnswers + result.correctAnswers,
      totalQuestions: currentStats.totalQuestions + result.totalQuestions,
      categoryScores: {
        ...currentStats.categoryScores,
        category ?? result.category: (currentStats.categoryScores[category ?? result.category] ?? 0) + result.correctAnswers,
      },
      totalScore: currentStats.totalScore + (score ?? result.score),
      bestStreak: newStreak > currentStats.bestStreak ? newStreak : currentStats.bestStreak,
      currentStreak: newStreak,
    );

    // Mettre à jour le niveau de la catégorie
    final categoryKey = category ?? result.category;
    final categoryScore = _userStats!.categoryScores[categoryKey] ?? 0;
    final categoryLevel = _userStats!.calculateLevel(categoryScore);
    
    _userStats = _userStats!.copyWith(
      categoryLevels: {
        ..._userStats!.categoryLevels,
        categoryKey: categoryLevel,
      },
    );

    // Vérifier les badges
    _checkBadges();

    // Sauvegarder
    await _storageService.saveUserStats(_userStats!.toJson());
    notifyListeners();
  }

  // Vérifier et attribuer les badges
  void _checkBadges() {
    if (_userStats == null) return;

    final badges = List<String>.from(_userStats!.badges);
    final stats = _userStats!;

    // Badge Premier Quiz
    if (stats.totalQuizzes >= 1 && !badges.contains('first_quiz')) {
      badges.add('first_quiz');
    }

    // Badge Streak Master
    if (stats.bestStreak >= 10 && !badges.contains('streak_master')) {
      badges.add('streak_master');
    }

    // Badge Perfectionniste
    if (stats.overallAccuracy >= 90 && stats.totalQuizzes >= 10 && !badges.contains('perfectionist')) {
      badges.add('perfectionist');
    }

    // Badge Marathon
    if (stats.totalQuizzes >= 50 && !badges.contains('marathon')) {
      badges.add('marathon');
    }

    // Badge Maître de Catégorie
    for (final category in stats.categoryScores.keys) {
      if (stats.categoryScores[category]! >= 100 && !badges.contains('master_$category')) {
        badges.add('master_$category');
      }
    }

    if (badges.length != _userStats!.badges.length) {
      _userStats = _userStats!.copyWith(badges: badges);
    }
  }

  // Débloquer une catégorie
  Future<void> unlockCategory(String category) async {
    if (_userStats == null) {
      await loadStats();
    }

    _userStats = _userStats!.copyWith(
      unlockedCategories: {
        ..._userStats!.unlockedCategories,
        category: true,
      },
    );

    await _storageService.saveUserStats(_userStats!.toJson());
    notifyListeners();
  }

  // Enregistrer l'utilisation d'un power-up
  Future<void> recordPowerUpUse(String powerUp) async {
    if (_userStats == null) {
      await loadStats();
    }

    _userStats = _userStats!.copyWith(
      powerUpsUsed: {
        ..._userStats!.powerUpsUsed,
        powerUp: (_userStats!.powerUpsUsed[powerUp] ?? 0) + 1,
      },
    );

    await _storageService.saveUserStats(_userStats!.toJson());
    notifyListeners();
  }

  // Réinitialiser toutes les stats
  Future<void> resetStats() async {
    _userStats = UserStatsModel(
      totalQuizzes: 0,
      totalCorrectAnswers: 0,
      totalQuestions: 0,
    );
    await _storageService.saveUserStats(_userStats!.toJson());
    notifyListeners();
  }
}

