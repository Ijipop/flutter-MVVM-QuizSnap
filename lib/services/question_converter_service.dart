import 'package:flutter/foundation.dart';
import '../models/question_model.dart';
import 'category_service.dart';

/// Service pour convertir le format OpenQuizzDB vers QuestionModel
class QuestionConverterService {
  /// Convertir un fichier JSON OpenQuizzDB en liste de QuestionModel
  static List<QuestionModel> convertOpenQuizzDBFormat(Map<String, dynamic> fileData) {
    final List<QuestionModel> questions = [];
    
    try {
      final theme = fileData['thème']?.toString() ?? 'Général';

      final quizz = fileData['quizz'];
      if (quizz == null || quizz is! Map<String, dynamic>) {
        return questions;
      }

      // Liste des codes de langue courants (pour détecter si c'est une langue ou un niveau)
      const languageCodes = ['fr', 'en', 'de', 'es', 'it', 'nl', 'pt', 'ru', 'ja', 'zh', 'ar'];
      // Langue souhaitée : uniquement le français
      const targetLanguage = 'fr';
      
      // Parcourir tous les éléments de quizz
      for (final key in quizz.keys) {
        final keyData = quizz[key];
        
        // Si c'est une langue, ne traiter QUE le français
        if (languageCodes.contains(key.toLowerCase())) {
          // Ignorer toutes les langues sauf le français
          if (key.toLowerCase() != targetLanguage) {
            continue;
          }
          if (keyData is Map<String, dynamic>) {
            // Structure avec langues : quizz.fr.débutant, quizz.fr.confirmé, etc.
            for (final level in keyData.keys) {
              final levelData = keyData[level];
              
              // Vérifier que c'est bien une liste
              if (levelData is! List) {
                continue;
              }
              
              final levelQuestions = levelData;
              if (levelQuestions.isEmpty) continue;
              
              // Traiter les questions de ce niveau (la difficulté sera déterminée depuis l'ID)
              _processQuestions(levelQuestions, theme, questions);
            }
          } else if (keyData is List) {
            // Structure avec liste d'objets : quizz.fr = [{débutant: [...]}, {confirmé: [...]}]
            for (final item in keyData) {
              if (item is Map<String, dynamic>) {
                // Chaque item est un objet avec une clé de niveau (débutant, confirmé, expert)
                for (final level in item.keys) {
                  final levelData = item[level];
                  if (levelData is List) {
                    final levelQuestions = levelData;
                    if (levelQuestions.isEmpty) continue;
                    
                    // Traiter les questions de ce niveau
                    _processQuestions(levelQuestions, theme, questions);
                  }
                }
              }
            }
          }
        } else if (keyData is List) {
          // Structure directe : quizz.débutant, quizz.confirmé, etc.
          final levelQuestions = keyData;
          if (levelQuestions.isEmpty) continue;
          
          // Traiter les questions de ce niveau
          _processQuestions(levelQuestions, theme, questions);
        } else if (keyData is Map<String, dynamic>) {
          // Cas spécial : structure imbriquée avec liste d'objets (ex: quizz.fr = [{débutant: [...]}])
          // Parcourir les éléments de la liste
          if (keyData.values.any((v) => v is List)) {
            for (final subKey in keyData.keys) {
              final subData = keyData[subKey];
              if (subData is List) {
                _processQuestions(subData, theme, questions);
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('❌ QuestionConverterService: Erreur lors de la conversion du format OpenQuizzDB: $e');
    }

    return questions;
  }

  /// Traiter une liste de questions et les ajouter à la collection
  static void _processQuestions(
    List<dynamic> levelQuestions,
    String theme,
    List<QuestionModel> questions,
  ) {
    for (final q in levelQuestions) {
      try {
        // Gérer le cas où la question est dans un objet avec le niveau comme clé
        Map<String, dynamic> questionData;
        if (q is Map<String, dynamic>) {
          // Vérifier si c'est un objet avec une structure imbriquée (ex: {débutant: [{question: ...}]})
          if (q.length == 1 && q.values.first is List) {
            // C'est une structure imbriquée, prendre la première liste
            final nestedList = q.values.first as List;
            for (final nestedQ in nestedList) {
              if (nestedQ is Map<String, dynamic>) {
                _addQuestion(nestedQ, theme, questions);
              }
            }
            continue;
          } else {
            questionData = q;
          }
        } else {
          continue;
        }
        
        _addQuestion(questionData, theme, questions);
      } catch (e) {
        // Ignorer les questions invalides
      }
    }
  }

  /// Ajouter une question à la collection
  /// La difficulté est déterminée depuis l'ID de la question :
  /// - ID 1-10 = easy (débutant)
  /// - ID 11-20 = medium (confirmé)
  /// - ID 21-30 = hard (expert)
  static void _addQuestion(
    Map<String, dynamic> questionData,
    String theme,
    List<QuestionModel> questions,
  ) {
    final questionText = questionData['question']?.toString() ?? '';
    final propositions = (questionData['propositions'] as List<dynamic>?)
        ?.map((p) => p.toString())
        .toList() ?? [];
    final reponse = questionData['réponse']?.toString() ?? '';
    final anecdote = questionData['anecdote']?.toString() ?? '';

    if (questionText.isEmpty || propositions.isEmpty || reponse.isEmpty) {
      return;
    }

    // Trouver l'index de la bonne réponse
    final correctIndex = propositions.indexOf(reponse);
    if (correctIndex == -1) return;

    // Récupérer l'ID de la question
    final questionIdRaw = questionData['id'];
    int questionIdNum = 0;
    
    // Parser l'ID (peut être un nombre ou une string)
    if (questionIdRaw is num) {
      questionIdNum = questionIdRaw.toInt();
    } else if (questionIdRaw is String) {
      questionIdNum = int.tryParse(questionIdRaw) ?? 0;
    }
    
    // Déterminer la difficulté depuis l'ID
    // ID 1-10 = facile, ID 11-20 = moyen, ID 21-30 = difficile
    String difficulty = 'medium'; // Par défaut
    if (questionIdNum >= 1 && questionIdNum <= 10) {
      difficulty = 'easy';
    } else if (questionIdNum >= 11 && questionIdNum <= 20) {
      difficulty = 'medium';
    } else if (questionIdNum >= 21 && questionIdNum <= 30) {
      difficulty = 'hard';
    }

    // Créer un ID unique
    final questionId = 'quizjson_${theme.hashCode}_$questionIdNum';

    questions.add(QuestionModel(
      id: questionId,
      category: CategoryService.normalizeCategory(theme),
      question: questionText,
      options: propositions,
      correctIndex: correctIndex,
      explanation: anecdote,
      difficulty: difficulty,
    ));
  }
}
