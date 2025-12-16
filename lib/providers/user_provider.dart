import 'package:flutter/foundation.dart';
import '../models/user_score.dart';
import '../models/quiz_result.dart';
import '../services/storage_service.dart';

// Provider pour gérer l'état utilisateur et les statistiques
class UserProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  UserScore? _userScore;
  List<QuizResult> _quizHistory = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  // Set pour tracker les résultats déjà sauvegardés (évite les doublons)
  final Set<String> _savedResultIds = {};
  // Flag pour éviter les appels simultanés à updateScore
  bool _isUpdatingScore = false;

  // Constructeur qui charge automatiquement les données au démarrage
  UserProvider() {
    // Lancer l'initialisation en arrière-plan
    _initialize();
  }

  // Initialiser et charger les données
  Future<void> _initialize() async {
    if (!_isInitialized) {
      await loadUserData();
      _isInitialized = true;
    }
  }

  // Getters
  UserScore? get userScore => _userScore;
  List<QuizResult> get quizHistory => _quizHistory;
  bool get isLoading => _isLoading;

  // Charger les données utilisateur
  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userScore = await _storageService.getUserScore();
      _quizHistory = await _storageService.getQuizHistory();
    } catch (e) {
      debugPrint('UserProvider: Erreur lors du chargement: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mettre à jour le score après un quiz
  Future<void> updateScore(QuizResult result) async {
    // Créer un identifiant unique pour ce résultat (basé sur catégorie + score + timestamp arrondi à la seconde)
    // Arrondir le timestamp à la seconde pour éviter les IDs différents pour le même quiz
    final timestampSeconds = (result.completedAt.millisecondsSinceEpoch / 1000).floor();
    final resultId = '${timestampSeconds}_${result.category}_${result.correctAnswers}_${result.totalQuestions}';
    
    // Vérifier si on est déjà en train de sauvegarder
    if (_isUpdatingScore) {
      return;
    }
    
    // Vérifier si ce résultat a déjà été sauvegardé
    if (_savedResultIds.contains(resultId)) {
      return;
    }
    
    // Vérifier aussi dans l'historique si un résultat similaire existe déjà (même catégorie, même score, même nombre de questions)
    // Recharger l'historique d'abord pour avoir les données à jour
    try {
      final currentHistory = await _storageService.getQuizHistory();
      final existingResult = currentHistory.firstWhere(
        (r) => r.category == result.category &&
               r.correctAnswers == result.correctAnswers &&
               r.totalQuestions == result.totalQuestions &&
               r.completedAt.difference(result.completedAt).inSeconds.abs() < 10, // Dans les 10 secondes
        orElse: () => QuizResult(
          totalQuestions: 0,
          correctAnswers: 0,
          score: 0,
          category: '',
          completedAt: DateTime.now(),
        ),
      );
      
      if (existingResult.totalQuestions > 0) {
        _savedResultIds.add(resultId); // Marquer comme sauvegardé pour éviter les futurs appels
        return;
      }
    } catch (e) {
      // Continuer même en cas d'erreur
    }
    
    _isUpdatingScore = true;
    try {
      // Marquer comme sauvegardé AVANT la sauvegarde pour éviter les appels simultanés
      _savedResultIds.add(resultId);
      
      // Sauvegarder le résultat immédiatement
      await _storageService.saveQuizResult(result);

      // Mettre à jour le score total
      final currentTotalQuizzes = _userScore?.totalQuizzes ?? 0;
      final currentTotalCorrect = _userScore?.totalCorrectAnswers ?? 0;
      final currentTotalQuestions = _userScore?.totalQuestions ?? 0;

      _userScore = UserScore(
        totalQuizzes: currentTotalQuizzes + 1,
        totalCorrectAnswers: currentTotalCorrect + result.correctAnswers,
        totalQuestions: currentTotalQuestions + result.totalQuestions,
        categoryScores: {
          ..._userScore?.categoryScores ?? {},
          result.category: (_userScore?.categoryScores[result.category] ?? 0) +
              result.correctAnswers,
        },
      );

      // Sauvegarder le score mis à jour immédiatement
      await _storageService.saveUserScore(_userScore!);
      
      // Recharger l'historique sans notifier (pour éviter les boucles)
      _isLoading = true;
      try {
        _quizHistory = await _storageService.getQuizHistory();
      } catch (e) {
        debugPrint('UserProvider: Erreur lors du rechargement de l\'historique: $e');
      } finally {
        _isLoading = false;
      }
      
      // Notifier les listeners une seule fois à la fin
      notifyListeners();
    } catch (e) {
      debugPrint('UserProvider: Erreur lors de la mise à jour du score: $e');
      // En cas d'erreur, retirer l'ID du Set pour permettre une nouvelle tentative
      _savedResultIds.remove(resultId);
      // Recharger les données normalement
      await loadUserData();
    } finally {
      _isUpdatingScore = false;
    }
  }

  // Réinitialiser toutes les données
  Future<void> resetAllData() async {
    await _storageService.clearAllData();
    _userScore = null;
    _quizHistory = [];
    notifyListeners();
  }
}

