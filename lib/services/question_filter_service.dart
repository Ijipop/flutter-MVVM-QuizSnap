import 'package:flutter/foundation.dart';
import '../models/question_model.dart';
import 'category_service.dart';

/// Service pour filtrer et récupérer des questions selon différents critères
class QuestionFilterService {
  /// Obtenir des questions aléatoires avec filtres optionnels
  static List<QuestionModel> getRandomQuestions({
    required List<QuestionModel> allQuestions,
    int count = 10,
    String? category,
    String? difficulty,
  }) {
    try {
      var questions = List<QuestionModel>.from(allQuestions);
      
      debugPrint('🔍 Filtrage: ${questions.length} questions disponibles');
      debugPrint('   Catégorie recherchée: $category');
      debugPrint('   Difficulté recherchée: "$difficulty" (type: ${difficulty.runtimeType}, isNull: ${difficulty == null}, isEmpty: ${difficulty?.isEmpty ?? true})');
      
      // Filtrer par catégorie si spécifiée
      if (category != null && category.isNotEmpty) {
        questions = _filterByCategory(questions, category);
      }
      
      // Filtrer par difficulté si spécifiée
      if (difficulty != null && difficulty.isNotEmpty) {
        final beforeCount = questions.length;
        questions = questions.where((q) => q.difficulty == difficulty).toList();
        debugPrint('   Après filtrage difficulté: ${questions.length} questions ($beforeCount -> ${questions.length})');
      }
      
      // Mélanger et prendre le nombre demandé
      questions.shuffle();
      final result = questions.take(count).toList();
      debugPrint('✅ ${result.length} questions sélectionnées');
      return result;
    } catch (e) {
      debugPrint('❌ QuestionFilterService: Erreur lors de la récupération de questions aléatoires: $e');
      return [];
    }
  }

  /// Filtrer les questions par catégorie
  static List<QuestionModel> _filterByCategory(
    List<QuestionModel> questions,
    String category,
  ) {
    final categoryLower = category.toLowerCase().trim();
    final beforeCount = questions.length;
    
    // Extraire la clé de catégorie parente depuis le nom (ex: "Cinema" -> "cinema")
    String? parentKey;
    final parentCategoryNames = {
      'cinema': ['cinéma', 'cinema', 'film'],
      'musique': ['musique', 'music'],
      'sport': ['sport'],
      'histoire': ['histoire', 'history'],
      'géographie': ['géographie', 'geographie', 'geography'],
      'sciences': ['science', 'sciences'],
      'littérature': ['littérature', 'litterature', 'literature'],
      'technologie': ['technologie', 'technology', 'tech'],
      'marques_et_commerce': ['marque', 'commerce', 'brand'],
      'culture_generale': ['culture', 'générale', 'generale', 'général', 'general'],
    };
    
    for (final entry in parentCategoryNames.entries) {
      if (entry.value.any((name) => categoryLower.contains(name))) {
        parentKey = entry.key;
        break;
      }
    }
    
    // Si c'est une catégorie parente identifiée
    if (parentKey != null) {
      questions = questions.where((q) {
        final qTheme = q.category.toLowerCase();
        final qParent = CategoryService.getParentCategory(qTheme);
        
        // Si c'est Culture générale, prendre toutes les questions qui n'ont pas de catégorie spécifique
        if (parentKey == 'culture_generale') {
          return qParent == 'culture_generale';
        }
        
        // Sinon, prendre toutes les questions de cette catégorie parente
        return qParent == parentKey;
      }).toList();
      
      debugPrint('   Catégorie parente détectée: $parentKey');
    } else {
      // Recherche exacte ou partielle sur le thème
      questions = questions.where((q) {
        final qCategory = q.category.toLowerCase().trim();
        // Recherche exacte ou partielle
        final matches = qCategory == categoryLower || 
                       qCategory.contains(categoryLower) || 
                       categoryLower.contains(qCategory);
        
        return matches;
      }).toList();
    }
    
    debugPrint('   Après filtrage catégorie: ${questions.length} questions ($beforeCount -> ${questions.length})');
    return questions;
  }
}
