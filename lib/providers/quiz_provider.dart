import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';
import '../models/category.dart' as models;
import '../services/local_data_service.dart';
import '../services/quiz_service.dart';

// Provider pour gérer l'état du quiz
class QuizProvider with ChangeNotifier {
  final QuizService _quizService = QuizService();

  List<Question> _questions = [];
  List<models.Category> _categories = [];
  Map<int, String> _userAnswers = {};
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  bool _isLoadingCategories = false;
  String? _error;
  QuizResult? _result;

  // Getters
  List<Question> get questions => _questions;
  List<models.Category> get categories => _categories;
  Map<int, String> get userAnswers => _userAnswers;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isLoading => _isLoading;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get error => _error;
  QuizResult? get result => _result;
  Question? get currentQuestion =>
      _currentQuestionIndex < _questions.length
          ? _questions[_currentQuestionIndex]
          : null;
  bool get isQuizComplete => _currentQuestionIndex >= _questions.length;

  // Charger les questions depuis les JSON locaux
  Future<void> loadQuestions({
    int amount = 10,
    int? category,
    String? difficulty,
    String? language,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Convertir category ID en string si nécessaire
      String? categoryString;
      if (category != null) {
        // Mapper l'ID numérique vers le string de catégorie JSON (clé parente)
        categoryString = _mapCategoryIdToString(category);
        debugPrint('📋 Catégorie ID $category -> "$categoryString"');
      }

      // Charger depuis LocalDataService
      final questionModels = await LocalDataService.getRandomQuestions(
        count: amount,
        category: categoryString,
        difficulty: difficulty,
      );

      // Convertir QuestionModel vers Question pour compatibilité
      _questions = questionModels.map((qm) => Question(
        id: qm.id,
        question: qm.question,
        answers: qm.options,
        correctAnswer: qm.correctAnswer,
        category: qm.category,
        difficulty: qm.difficulty,
      )).toList();

      _currentQuestionIndex = 0;
      _userAnswers = {};
      _result = null;

      if (_questions.isEmpty) {
        _error = 'Aucune question disponible pour cette catégorie';
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Erreur lors du chargement des questions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mapper l'ID numérique vers le string de catégorie JSON
  String? _mapCategoryIdToString(int? categoryId) {
    if (categoryId == null) return null;
    return _categoryIdMapping[categoryId];
  }

  // Répondre à une question
  void answerQuestion(String answer) {
    _userAnswers[_currentQuestionIndex] = answer;
    notifyListeners();
  }

  // Passer à la question suivante
  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  // Question précédente
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  // Terminer le quiz et calculer le résultat
  void finishQuiz(String category) {
    _result = _quizService.createResult(
      questions: _questions,
      userAnswers: _userAnswers,
      category: category,
    );
    notifyListeners();
  }

  // Charger les catégories depuis les JSON locaux (générées dynamiquement depuis Quiz_Json)
  Future<void> loadCategories() async {
    _isLoadingCategories = true;
    _error = null;
    notifyListeners();

    try {
      final categoriesData = await LocalDataService.loadCategories();
      
      // Convertir les données JSON vers le modèle Category
      // Les IDs JSON sont des strings (thèmes normalisés), on les convertit en hash pour avoir des IDs numériques
      _categories = categoriesData.map((json) {
        final idString = json['id']?.toString() ?? '';
        // Convertir le string ID en hash numérique pour compatibilité
        final numericId = idString.hashCode.abs();
        
        return models.Category(
          id: numericId,
          name: json['name'] ?? '',
        );
      }).toList();

      // Stocker le mapping ID numérique -> ID string JSON (clé de catégorie parente)
      _categoryIdMapping = {};
      for (final json in categoriesData) {
        final idString = json['id']?.toString() ?? ''; // Clé parente (ex: "cinema", "musique")
        final numericId = idString.hashCode.abs();
        _categoryIdMapping[numericId] = idString;
      }

      debugPrint('✅ ${_categories.length} catégories parentes chargées');
      debugPrint('   Mapping: $_categoryIdMapping');

      if (_categories.isEmpty) {
        _error = 'Aucune catégorie disponible';
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Erreur lors du chargement des catégories: $e');
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  // Mapping pour convertir ID numérique vers ID string JSON
  Map<int, String> _categoryIdMapping = {};

  // Réinitialiser le quiz
  void resetQuiz() {
    _questions = [];
    _userAnswers = {};
    _currentQuestionIndex = 0;
    _result = null;
    _error = null;
    notifyListeners();
  }
}

