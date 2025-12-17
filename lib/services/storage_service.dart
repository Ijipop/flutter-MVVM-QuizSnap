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
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(score.toJson());
      
      // Sauvegarder
      final success = await prefs.setString(_userScoreKey, jsonData);
      if (!success) {
        throw Exception('Failed to save user score');
      }
      
      // Vérifier immédiatement que les données sont bien sauvegardées
      final verification = prefs.getString(_userScoreKey);
      if (verification == null || verification != jsonData) {
        throw Exception('Verification failed after save');
      }
    } catch (e) {
      debugPrint('❌ StorageService: Erreur lors de la sauvegarde: $e');
      throw Exception('Error saving user score: $e');
    }
  }

  // Récupérer le score utilisateur
  Future<UserScore?> getUserScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scoreJson = prefs.getString(_userScoreKey);
      
      if (scoreJson != null) {
        return UserScore.fromJson(jsonDecode(scoreJson));
      }
      return null;
    } catch (e) {
      debugPrint('❌ StorageService: Erreur lors de la récupération: $e');
      return null;
    }
  }

  // Sauvegarder un résultat de quiz
  Future<void> saveQuizResult(QuizResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_quizHistoryKey) ?? '[]';
      final history = (jsonDecode(historyJson) as List)
          .map((e) => QuizResult.fromJson(e))
          .toList();
      
      history.add(result);
      
      final newHistoryJson = jsonEncode(history.map((e) => e.toJson()).toList());
      final success = await prefs.setString(
        _quizHistoryKey,
        newHistoryJson,
      );
      if (!success) {
        throw Exception('Failed to save quiz result');
      }
      
      // Vérifier immédiatement que les données sont bien sauvegardées
      final verification = prefs.getString(_quizHistoryKey);
      if (verification == null || verification != newHistoryJson) {
        throw Exception('Verification failed after save');
      }
    } catch (e) {
      debugPrint('❌ StorageService: Erreur lors de la sauvegarde du résultat: $e');
      throw Exception('Error saving quiz result: $e');
    }
  }

  // Récupérer l'historique des quiz
  Future<List<QuizResult>> getQuizHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_quizHistoryKey) ?? '[]';
      
      return (jsonDecode(historyJson) as List)
          .map((e) => QuizResult.fromJson(e))
          .toList();
    } catch (e) {
      debugPrint('❌ StorageService: Erreur lors de la récupération de l\'historique: $e');
      return [];
    }
  }

  // Réinitialiser toutes les données
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userScoreKey);
    await prefs.remove(_quizHistoryKey);
  }

}

