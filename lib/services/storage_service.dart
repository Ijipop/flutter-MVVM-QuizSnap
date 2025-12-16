import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_score.dart';
import '../models/quiz_result.dart';

// Service pour le stockage local
class StorageService {
  static const String _userScoreKey = 'user_score';
  static const String _quizHistoryKey = 'quiz_history';

  // Sauvegarder le score utilisateur
  Future<void> saveUserScore(UserScore score) async {
    try {
      debugPrint('💾 StorageService: Sauvegarde du score utilisateur...');
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(score.toJson());
      debugPrint('   Données JSON: $jsonData');
      
      // Sauvegarder
      final success = await prefs.setString(_userScoreKey, jsonData);
      if (!success) {
        debugPrint('❌ StorageService: Échec de la sauvegarde');
        throw Exception('Failed to save user score');
      }
      
      // Vérifier immédiatement que les données sont bien sauvegardées
      final verification = prefs.getString(_userScoreKey);
      if (verification == null || verification != jsonData) {
        debugPrint('❌ StorageService: Échec de la vérification après sauvegarde');
        throw Exception('Verification failed after save');
      }
      
      debugPrint('✅ StorageService: Score sauvegardé et vérifié avec succès');
    } catch (e) {
      debugPrint('❌ StorageService: Erreur lors de la sauvegarde: $e');
      throw Exception('Error saving user score: $e');
    }
  }

  // Récupérer le score utilisateur
  Future<UserScore?> getUserScore() async {
    try {
      debugPrint('📥 StorageService: Récupération du score utilisateur...');
      final prefs = await SharedPreferences.getInstance();
      
      // Déboguer : lister toutes les clés disponibles
      final allKeys = prefs.getKeys();
      debugPrint('   Clés disponibles dans SharedPreferences: ${allKeys.length}');
      if (allKeys.isNotEmpty) {
        debugPrint('   Clés: ${allKeys.join(", ")}');
      }
      
      final scoreJson = prefs.getString(_userScoreKey);
      
      if (scoreJson != null) {
        debugPrint('✅ StorageService: Score trouvé dans le stockage');
        debugPrint('   Données JSON: $scoreJson');
        final score = UserScore.fromJson(jsonDecode(scoreJson));
        debugPrint('   Score décodé: ${score.totalQuizzes} quiz');
        return score;
      } else {
        debugPrint('ℹ️ StorageService: Aucun score trouvé dans le stockage');
        debugPrint('   Clé recherchée: $_userScoreKey');
        return null;
      }
    } catch (e) {
      debugPrint('❌ StorageService: Erreur lors de la récupération: $e');
      return null;
    }
  }

  // Sauvegarder un résultat de quiz
  Future<void> saveQuizResult(QuizResult result) async {
    try {
      debugPrint('💾 StorageService: Sauvegarde du résultat du quiz...');
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_quizHistoryKey) ?? '[]';
      final history = (jsonDecode(historyJson) as List)
          .map((e) => QuizResult.fromJson(e))
          .toList();
      
      debugPrint('   Historique actuel: ${history.length} résultats');
      history.add(result);
      debugPrint('   Nouveau historique: ${history.length} résultats');
      
      final newHistoryJson = jsonEncode(history.map((e) => e.toJson()).toList());
      final success = await prefs.setString(
        _quizHistoryKey,
        newHistoryJson,
      );
      if (!success) {
        debugPrint('❌ StorageService: Échec de la sauvegarde du résultat');
        throw Exception('Failed to save quiz result');
      }
      
      // Vérifier immédiatement que les données sont bien sauvegardées
      final verification = prefs.getString(_quizHistoryKey);
      if (verification == null || verification != newHistoryJson) {
        debugPrint('❌ StorageService: Échec de la vérification après sauvegarde');
        throw Exception('Verification failed after save');
      }
      
      debugPrint('✅ StorageService: Résultat sauvegardé et vérifié avec succès');
    } catch (e) {
      debugPrint('❌ StorageService: Erreur lors de la sauvegarde du résultat: $e');
      throw Exception('Error saving quiz result: $e');
    }
  }

  // Récupérer l'historique des quiz
  Future<List<QuizResult>> getQuizHistory() async {
    try {
      debugPrint('📥 StorageService: Récupération de l\'historique...');
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_quizHistoryKey) ?? '[]';
      
      final history = (jsonDecode(historyJson) as List)
          .map((e) => QuizResult.fromJson(e))
          .toList();
      
      debugPrint('✅ StorageService: ${history.length} résultats trouvés dans l\'historique');
      return history;
    } catch (e) {
      debugPrint('❌ StorageService: Erreur lors de la récupération de l\'historique: $e');
      return [];
    }
  }

  // Réinitialiser toutes les données
  Future<void> clearAllData() async {
    debugPrint('🗑️ StorageService: Suppression de toutes les données...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userScoreKey);
    await prefs.remove(_quizHistoryKey);
    debugPrint('✅ StorageService: Toutes les données supprimées');
  }

}

