import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/question_model.dart';
import 'json_parser_service.dart';
import 'question_converter_service.dart';
import 'category_service.dart';
import 'question_filter_service.dart';

/// Service principal pour charger les données JSON locales
/// Orchestre les différents services spécialisés
class LocalDataService {
  static List<QuestionModel>? _cachedQuestions;

  /// Charger les questions depuis les fichiers JSON (UNIQUEMENT Quiz_Json)
  static Future<List<QuestionModel>> loadQuestions() async {
    // Retourner le cache si disponible
    if (_cachedQuestions != null) {
      return _cachedQuestions!;
    }

    try {
      debugPrint('LocalDataService: Chargement des questions depuis Quiz_Json...');
      
      // Charger UNIQUEMENT depuis Quiz_Json
      final quizJsonQuestions = await _loadQuizJsonFiles();
      
      _cachedQuestions = quizJsonQuestions;
      debugPrint('LocalDataService: ${quizJsonQuestions.length} questions chargées depuis Quiz_Json/');
      return quizJsonQuestions;
    } catch (e) {
      debugPrint('LocalDataService: Erreur lors du chargement des questions: $e');
      return [];
    }
  }

  /// Charger tous les fichiers JSON du dossier Quiz_Json
  static Future<List<QuestionModel>> _loadQuizJsonFiles() async {
    final List<QuestionModel> questions = [];
    
    try {
      // Obtenir la liste de tous les fichiers dans Quiz_Json
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestContent);
      
      // Filtrer les fichiers JSON de Quiz_Json (insensible à la casse)
      final quizJsonFiles = manifest.keys
          .where((key) => key.toLowerCase().startsWith('data/quiz_json/') && key.endsWith('.json'))
          .toList();

      debugPrint('${quizJsonFiles.length} fichiers JSON trouvés dans Quiz_Json');
      
      // Debug: vérifier si openjiquiz.json est dans la liste
      final openjiquizFound = quizJsonFiles.any((path) => path.toLowerCase().contains('openjiquiz'));
      debugPrint('   openjiquiz.json trouvé: $openjiquizFound');
      if (openjiquizFound) {
        final openjiquizPath = quizJsonFiles.firstWhere((path) => path.toLowerCase().contains('openjiquiz'));
        debugPrint('   Chemin: $openjiquizPath');
      }

      // Charger chaque fichier
      for (final filePath in quizJsonFiles) {
        try {
          final fileName = filePath.split('/').last;
          debugPrint('   Chargement de $fileName...');
          
          final fileContent = await rootBundle.loadString(filePath);
          
          // Utiliser JsonParserService pour parser et nettoyer le JSON
          final fileData = JsonParserService.parseAndCleanJson(fileContent);
          
          // Utiliser QuestionConverterService pour convertir le format OpenQuizzDB
          final convertedQuestions = QuestionConverterService.convertOpenQuizzDBFormat(fileData);
          if (convertedQuestions.isNotEmpty) {
            questions.addAll(convertedQuestions);
            debugPrint('    ✅ ${convertedQuestions.length} questions chargées depuis $fileName');
          } else {
            debugPrint('    ⚠️ Aucune question convertie depuis $fileName');
          }
        } catch (e, stackTrace) {
          debugPrint('    ❌ Erreur lors du chargement de ${filePath.split('/').last}: $e');
          debugPrint('       Stack trace: $stackTrace');
          // Continuer avec les autres fichiers - ne pas bloquer tout le chargement
        }
      }
    } catch (e) {
      debugPrint(' Erreur lors du chargement des fichiers Quiz_Json: $e');
    }

    return questions;
  }

  /// Générer les catégories dynamiquement depuis les thèmes des fichiers Quiz_Json
  static Future<List<Map<String, dynamic>>> loadCategories() async {
    // Vider le cache pour s'assurer d'avoir les données à jour
    clearCache();
    final questions = await loadQuestions();
    return CategoryService.loadCategories(questions);
  }

  /// Obtenir des questions aléatoires avec filtres optionnels
  static Future<List<QuestionModel>> getRandomQuestions({
    int count = 10,
    String? category,
    String? difficulty,
  }) async {
    try {
      final allQuestions = await loadQuestions();
      return QuestionFilterService.getRandomQuestions(
        allQuestions: allQuestions,
        count: count,
        category: category,
        difficulty: difficulty,
      );
    } catch (e) {
      debugPrint('❌ LocalDataService: Erreur lors de la récupération de questions aléatoires: $e');
      return [];
    }
  }

  /// Réinitialiser le cache (utile pour recharger après modification)
  static void clearCache() {
    _cachedQuestions = null;
  }
}
