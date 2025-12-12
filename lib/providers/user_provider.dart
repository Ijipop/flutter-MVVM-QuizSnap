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

  // Constructeur qui charge automatiquement les données au démarrage
  UserProvider() {
    // Lancer l'initialisation en arrière-plan
    _initialize();
  }

  // Initialiser et charger les données
  Future<void> _initialize() async {
    if (!_isInitialized) {
      debugPrint('🔄 UserProvider: Initialisation en cours...');
      await loadUserData();
      _isInitialized = true;
      debugPrint('✅ UserProvider: Initialisation terminée');
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
      debugPrint('📥 UserProvider: Chargement des données...');
      
      // Déboguer le stockage avant de charger
      await _storageService.debugStorage();
      
      _userScore = await _storageService.getUserScore();
      _quizHistory = await _storageService.getQuizHistory();
      
      debugPrint('📊 UserProvider: Données chargées - Quiz: ${_userScore?.totalQuizzes ?? 0}, Historique: ${_quizHistory.length}');
      
      if (_userScore != null) {
        debugPrint('✅ UserProvider: Score trouvé - Total: ${_userScore!.totalQuizzes} quiz, ${_userScore!.totalCorrectAnswers}/${_userScore!.totalQuestions} réponses');
      } else {
        debugPrint('ℹ️ UserProvider: Aucun score sauvegardé');
      }
    } catch (e) {
      debugPrint('❌ UserProvider: Erreur lors du chargement: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mettre à jour le score après un quiz
  Future<void> updateScore(QuizResult result) async {
    try {
      debugPrint('💾 UserProvider: Sauvegarde du résultat du quiz...');
      debugPrint('   Catégorie: ${result.category}, Score: ${result.correctAnswers}/${result.totalQuestions}');
      
      // Sauvegarder le résultat immédiatement
      await _storageService.saveQuizResult(result);
      debugPrint('✅ UserProvider: Résultat sauvegardé');

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

      debugPrint('💾 UserProvider: Sauvegarde du score total...');
      debugPrint('   Nouveau total: ${_userScore!.totalQuizzes} quiz, ${_userScore!.totalCorrectAnswers}/${_userScore!.totalQuestions} réponses');
      
      // Sauvegarder le score mis à jour immédiatement
      await _storageService.saveUserScore(_userScore!);
      debugPrint('✅ UserProvider: Score total sauvegardé');
      
      // Vérifier que la sauvegarde a bien fonctionné
      final verification = await _storageService.getUserScore();
      if (verification != null) {
        debugPrint('✅ UserProvider: Vérification - Score sauvegardé: ${verification.totalQuizzes} quiz');
      } else {
        debugPrint('⚠️ UserProvider: Vérification - Score non trouvé après sauvegarde!');
      }
      
      // Notifier les listeners pour mettre à jour l'UI
      notifyListeners();
      
      // Recharger pour avoir l'historique à jour
      await loadUserData();
      debugPrint('✅ UserProvider: Données rechargées après mise à jour');
    } catch (e) {
      debugPrint('❌ UserProvider: Erreur lors de la mise à jour du score: $e');
      // En cas d'erreur, recharger quand même les données
      await loadUserData();
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

