import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/question_model.dart';

/// Service pour gérer les catégories (normalisation, classification, génération)
class CategoryService {
  /// Normaliser le nom de catégorie (PRÉSERVE les accents français)
  static String normalizeCategory(String theme) {
    // Simplifier le nom de catégorie tout en préservant les accents français
    // On garde toutes les lettres (y compris accentuées), chiffres et espaces
    // On enlève seulement la ponctuation spécifique
    
    var normalized = theme
        .toLowerCase()
        .replaceAll(RegExp(r'\([^)]*\)'), '') // Enlever les parenthèses et leur contenu
        .trim();
    
    // Remplacer seulement les caractères de ponctuation par rien, mais garder les lettres accentuées
    final punctuation = ['.', ',', ';', ':', '!', '?', '-', '_', '=', '+', '*', '&', '%', '\$', '#', '@', '[', ']', '{', '}', '|', '\\', '/', '<', '>', '"', "'", '`', '~'];
    for (final char in punctuation) {
      normalized = normalized.replaceAll(char, '');
    }
    
    // Remplacer les espaces multiples par un seul underscore
    normalized = normalized.replaceAll(RegExp(r'\s+'), '_');
    
    return normalized;
  }

  /// Déterminer la catégorie parente d'un thème (retourne toujours une catégorie)
  static String getParentCategory(String theme) {
    final themeLower = theme.toLowerCase();
    
    // Mots-clés pour identifier les catégories parentes
    if (themeLower.contains('cinema') || themeLower.contains('film') || 
        themeLower.contains('acteur') || themeLower.contains('actrice') ||
        themeLower.contains('réalisateur') || themeLower.contains('oscar') ||
        themeLower.contains('césar') || themeLower.contains('festival')) {
      return 'cinema';
    }
    
    if (themeLower.contains('musique') || themeLower.contains('chanson') ||
        themeLower.contains('artiste') || themeLower.contains('groupe') ||
        themeLower.contains('album') || themeLower.contains('concert') ||
        themeLower.contains('festival') && themeLower.contains('musique')) {
      return 'musique';
    }
    
    if (themeLower.contains('sport') || themeLower.contains('football') ||
        themeLower.contains('basket') || themeLower.contains('tennis') ||
        themeLower.contains('olympique') || themeLower.contains('championnat')) {
      return 'sport';
    }
    
    if (themeLower.contains('histoire') || themeLower.contains('historique') ||
        themeLower.contains('guerre') || themeLower.contains('roi') ||
        themeLower.contains('reine') || themeLower.contains('empire')) {
      return 'histoire';
    }
    
    if (themeLower.contains('géographie') || themeLower.contains('pays') ||
        themeLower.contains('ville') || themeLower.contains('capitale') ||
        themeLower.contains('continent') || themeLower.contains('fleuve') ||
        themeLower.contains('montagne')) {
      return 'géographie';
    }
    
    if (themeLower.contains('science') || themeLower.contains('physique') ||
        themeLower.contains('chimie') || themeLower.contains('biologie') ||
        themeLower.contains('math') || themeLower.contains('astronomie')) {
      return 'sciences';
    }
    
    if (themeLower.contains('littérature') || themeLower.contains('livre') ||
        themeLower.contains('auteur') || themeLower.contains('écrivain') ||
        themeLower.contains('roman') || themeLower.contains('poésie')) {
      return 'littérature';
    }
    
    if (themeLower.contains('technologie') || themeLower.contains('informatique') ||
        themeLower.contains('ordinateur') || themeLower.contains('internet') ||
        themeLower.contains('logiciel') || themeLower.contains('application')) {
      return 'technologie';
    }
    
    if (themeLower.contains('marque') || themeLower.contains('logo') ||
        themeLower.contains('slogan') || themeLower.contains('publicité') ||
        themeLower.contains('entreprise') || themeLower.contains('commerce')) {
      return 'marques_et_commerce';
    }
    
    // Par défaut, tout va dans Culture générale
    return 'culture_generale';
  }

  /// Générer les catégories dynamiquement depuis les thèmes des fichiers Quiz_Json
  static Future<List<Map<String, dynamic>>> loadCategories(
    List<QuestionModel> questions,
  ) async {
    try {
      // Extraire les thèmes uniques et les regrouper par catégorie parente
      final themes = <String, int>{};
      final themesByParent = <String, Map<String, int>>{};
      
      for (final q in questions) {
        final theme = q.category;
        themes[theme] = (themes[theme] ?? 0) + 1;
        
        // Grouper par catégorie parente
        final parent = getParentCategory(theme);
        themesByParent.putIfAbsent(parent, () => {});
        themesByParent[parent]![theme] = (themesByParent[parent]![theme] ?? 0) + 1;
      }

      // Créer les catégories parentes d'abord
      final categories = <Map<String, dynamic>>[];
      final parentCategoryNames = {
        'cinema': '🎬 Cinéma',
        'musique': '🎵 Musique',
        'sport': '⚽ Sport',
        'histoire': '📜 Histoire',
        'géographie': '🌍 Géographie',
        'sciences': '🔬 Sciences',
        'littérature': '📚 Littérature',
        'technologie': '💻 Technologie',
        'marques_et_commerce': '🏢 Marques & Commerce',
        'culture_generale': '🌟 Culture Générale',
      };
      
      int parentIndex = 0;
      
      // Créer les catégories parentes
      for (final parentEntry in themesByParent.entries) {
        final parentKey = parentEntry.key;
        final subThemes = parentEntry.value;
        final totalQuestions = subThemes.values.fold(0, (sum, count) => sum + count);
        
        final parentName = parentCategoryNames[parentKey] ?? 
            parentKey.replaceAll('_', ' ').split(' ').map((w) => 
                w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1)).join(' ');
        
        categories.add({
          'id': parentKey,
          'name': parentName,
          'description': '$totalQuestions questions disponibles',
          'icon': 'quiz',
          'color': '#${_getColorForIndex(parentIndex).toRadixString(16).substring(2)}',
          'unlocked': true,
          'level': 1,
          'isParent': true,
          'subCategories': subThemes.length,
        });
        
        parentIndex++;
      }

      // Trier par nombre de questions (décroissant)
      categories.sort((a, b) {
        final countA = int.tryParse(a['description'].toString().split(' ').first) ?? 0;
        final countB = int.tryParse(b['description'].toString().split(' ').first) ?? 0;
        return countB.compareTo(countA);
      });

      return categories;
    } catch (e) {
      debugPrint('❌ CategoryService: Erreur lors de la génération des catégories: $e');
      // Fallback vers categories_data.json si erreur
      try {
        final String jsonString = await rootBundle.loadString('data/categories_data.json');
        final List<dynamic> jsonData = json.decode(jsonString);
        return jsonData.map((json) => json as Map<String, dynamic>).toList();
      } catch (e2) {
        return [];
      }
    }
  }

  /// Générer une couleur pour chaque catégorie (retourne la valeur hex)
  static int _getColorForIndex(int index) {
    final colors = [
      0xFF4CAF50, // Vert
      0xFF2196F3, // Bleu
      0xFFFF9800, // Orange
      0xFF9C27B0, // Violet
      0xFFF44336, // Rouge
      0xFFE91E63, // Rose
      0xFF00BCD4, // Cyan
      0xFFFFC107, // Jaune
      0xFF795548, // Marron
      0xFF607D8B, // Bleu gris
    ];
    return colors[index % colors.length];
  }
}
