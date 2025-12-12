import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/question_model.dart';

// Service pour charger les données JSON locales
class LocalDataService {
  static List<QuestionModel>? _cachedQuestions;

  // Charger les questions depuis les fichiers JSON (UNIQUEMENT Quiz_Json)
  static Future<List<QuestionModel>> loadQuestions() async {
    // Retourner le cache si disponible
    if (_cachedQuestions != null) {
      return _cachedQuestions!;
    }

    try {
      debugPrint('📥 LocalDataService: Chargement des questions depuis Quiz_Json...');
      
      // Charger UNIQUEMENT depuis Quiz_Json
      final quizJsonQuestions = await _loadQuizJsonFiles();
      
      _cachedQuestions = quizJsonQuestions;
      debugPrint('✅ LocalDataService: ${quizJsonQuestions.length} questions chargées depuis Quiz_Json/');
      return quizJsonQuestions;
    } catch (e) {
      debugPrint('❌ LocalDataService: Erreur lors du chargement des questions: $e');
      return [];
    }
  }

  // Charger tous les fichiers JSON du dossier Quiz_Json
  static Future<List<QuestionModel>> _loadQuizJsonFiles() async {
    final List<QuestionModel> questions = [];
    
    try {
      // Obtenir la liste de tous les fichiers dans Quiz_Json
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestContent);
      
      // Filtrer les fichiers JSON de Quiz_Json
      final quizJsonFiles = manifest.keys
          .where((key) => key.startsWith('data/Quiz_Json/') && key.endsWith('.json'))
          .toList();

      debugPrint('📂 ${quizJsonFiles.length} fichiers JSON trouvés dans Quiz_Json');

      // Charger chaque fichier
      for (final filePath in quizJsonFiles) {
        try {
          final fileContent = await rootBundle.loadString(filePath);
          
          // Corriger les problèmes de syntaxe JSON courants
          String correctedContent = fileContent;
          
          // 1. Remplacer "difficulté": 2 / 5 par "difficulté": 2.0
          correctedContent = correctedContent.replaceAllMapped(
            RegExp(r'"difficulté":\s*(\d+)\s*/\s*(\d+)'),
            (match) {
              final num = int.parse(match.group(1)!);
              final den = int.parse(match.group(2)!);
              final value = num / den;
              return '"difficulté": $value';
            },
          );
          
          // 2. Corriger les cas où un retour à la ligne brise une string (comme ligne 240)
          // Pattern: "texte...\n" -> "texte...\\n"
          correctedContent = correctedContent.replaceAllMapped(
            RegExp(r'":\s*"([^"]*?)\r?\n\s*"', multiLine: true),
            (match) {
              final text = match.group(1) ?? '';
              return '": "${text.replaceAll('\n', '\\n').replaceAll('\r', '\\r')}"';
            },
          );
          
          // 3. Nettoyer les caractères de contrôle invalides dans les strings JSON restantes
          // Échapper les retours à la ligne, tabulations, etc. dans les strings
          correctedContent = correctedContent.replaceAllMapped(
            RegExp(r'"(?:[^"\\]|\\.)*"', dotAll: true),
            (match) {
              String str = match.group(0)!;
              // Échapper les caractères de contrôle non déjà échappés
              str = str.replaceAllMapped(
                RegExp(r'(?<!\\)[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]'),
                (m) {
                  final char = m.group(0)!;
                  if (char == '\n') return '\\n';
                  if (char == '\r') return '\\r';
                  if (char == '\t') return '\\t';
                  return ' '; // Remplacer les autres caractères de contrôle par un espace
                },
              );
              return str;
            },
          );
          
          final fileData = json.decode(correctedContent) as Map<String, dynamic>;
          
          // Convertir le format OpenQuizzDB vers QuestionModel
          final convertedQuestions = _convertOpenQuizzDBFormat(fileData);
          if (convertedQuestions.isNotEmpty) {
            questions.addAll(convertedQuestions);
            debugPrint('   ✅ ${convertedQuestions.length} questions chargées depuis ${filePath.split('/').last}');
          }
        } catch (e) {
          debugPrint('⚠️ Erreur lors du chargement de $filePath: $e');
          // Continuer avec les autres fichiers - ne pas bloquer tout le chargement
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement des fichiers Quiz_Json: $e');
    }

    return questions;
  }

  // Convertir le format OpenQuizzDB vers QuestionModel
  static List<QuestionModel> _convertOpenQuizzDBFormat(Map<String, dynamic> fileData) {
    final List<QuestionModel> questions = [];
    
    try {
      final theme = fileData['thème']?.toString() ?? 'Général';
      
      // Convertir la difficulté selon l'échelle 1/5 à 5/5
      // 1/5 et 2/5 → facile (easy)
      // 3/5 → moyen (medium)
      // 4/5 et 5/5 → difficile (hard)
      String difficulty = 'medium';
      try {
        final difficultyRaw = fileData['difficulté'];
        if (difficultyRaw != null) {
          if (difficultyRaw is num) {
            final diffValue = difficultyRaw.toDouble();
            // Si c'est une fraction (0.0 à 1.0), multiplier par 5 pour obtenir l'échelle 1-5
            final scaleValue = diffValue < 1.0 ? diffValue * 5 : diffValue;
            
            // Nouvelle logique : 1-2 = easy, 3 = medium, 4-5 = hard
            if (scaleValue <= 2) {
              difficulty = 'easy';
            } else if (scaleValue <= 3) {
              difficulty = 'medium';
            } else {
              difficulty = 'hard';
            }
          } else if (difficultyRaw is String) {
            // Parser "2 / 5" -> extraire le numérateur (2) et dénominateur (5)
            final match = RegExp(r'(\d+)\s*/\s*(\d+)').firstMatch(difficultyRaw);
            if (match != null) {
              final numerator = int.parse(match.group(1)!);
              final denominator = int.parse(match.group(2)!);
              final scaleValue = denominator > 0 ? (numerator / denominator) * 5 : numerator;
              
              // Nouvelle logique : 1-2 = easy, 3 = medium, 4-5 = hard
              if (scaleValue <= 2) {
                difficulty = 'easy';
              } else if (scaleValue <= 3) {
                difficulty = 'medium';
              } else {
                difficulty = 'hard';
              }
            } else {
              // Fallback : essayer de trouver juste un nombre
              final simpleMatch = RegExp(r'(\d+)').firstMatch(difficultyRaw);
              if (simpleMatch != null) {
                final diffValue = int.parse(simpleMatch.group(1)!);
                if (diffValue <= 2) {
                  difficulty = 'easy';
                } else if (diffValue <= 3) {
                  difficulty = 'medium';
                } else {
                  difficulty = 'hard';
                }
              }
            }
          }
        }
      } catch (e) {
        // Si le parsing échoue, utiliser la valeur par défaut
        debugPrint('⚠️ Impossible de parser la difficulté, utilisation de "medium" par défaut');
        difficulty = 'medium';
      }

      final quizz = fileData['quizz'];
      if (quizz == null || quizz is! Map<String, dynamic>) {
        debugPrint('⚠️ "quizz" n\'est pas une Map valide');
        return questions;
      }

      // Parcourir tous les niveaux (débutant, confirmé, expert, etc.)
      for (final level in quizz.keys) {
        final levelData = quizz[level];
        
        // Vérifier que c'est bien une liste
        if (levelData is! List) {
          debugPrint('⚠️ Le niveau "$level" n\'est pas une liste (type: ${levelData.runtimeType}), ignoré');
          continue;
        }
        
        final levelQuestions = levelData;
        if (levelQuestions.isEmpty) continue;

        // Déterminer la difficulté selon le niveau
        // Utiliser le niveau (débutant, confirmé, expert) pour déterminer la difficulté
        // plutôt que seulement la difficulté globale du fichier
        String questionDifficulty = _getDifficultyFromLevel(level, difficulty);

        for (final q in levelQuestions) {
          try {
            final questionData = q as Map<String, dynamic>;
            final questionText = questionData['question']?.toString() ?? '';
            final propositions = (questionData['propositions'] as List<dynamic>?)
                ?.map((p) => p.toString())
                .toList() ?? [];
            final reponse = questionData['réponse']?.toString() ?? '';
            final anecdote = questionData['anecdote']?.toString() ?? '';

            if (questionText.isEmpty || propositions.isEmpty || reponse.isEmpty) {
              continue;
            }

            // Trouver l'index de la bonne réponse
            final correctIndex = propositions.indexOf(reponse);
            if (correctIndex == -1) continue;

            // Créer un ID unique
            final questionId = 'quizjson_${theme.hashCode}_${questionData['id'] ?? DateTime.now().millisecondsSinceEpoch}';

            questions.add(QuestionModel(
              id: questionId,
              category: _normalizeCategory(theme),
              question: questionText,
              options: propositions,
              correctIndex: correctIndex,
              explanation: anecdote,
              difficulty: questionDifficulty, // Utiliser la difficulté basée sur le niveau
              type: QuestionType.multipleChoice,
            ));
          } catch (e) {
            debugPrint('⚠️ Erreur lors de la conversion d\'une question: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la conversion du format OpenQuizzDB: $e');
    }

    return questions;
  }

  // Déterminer la difficulté selon le niveau (débutant, confirmé, expert, etc.)
  static String _getDifficultyFromLevel(String level, String defaultDifficulty) {
    final levelLower = level.toLowerCase();
    
    // Mapping des niveaux vers les difficultés
    if (levelLower.contains('débutant') || levelLower.contains('debutant') || 
        levelLower.contains('facile') || levelLower.contains('easy') ||
        levelLower.contains('niveau 1') || levelLower.contains('niveau1')) {
      return 'easy';
    }
    
    if (levelLower.contains('expert') || levelLower.contains('difficile') ||
        levelLower.contains('hard') || levelLower.contains('niveau 3') ||
        levelLower.contains('niveau3') || levelLower.contains('avancé') ||
        levelLower.contains('avance')) {
      return 'hard';
    }
    
    if (levelLower.contains('confirmé') || levelLower.contains('confirme') ||
        levelLower.contains('intermédiaire') || levelLower.contains('intermediaire') ||
        levelLower.contains('medium') || levelLower.contains('moyen') ||
        levelLower.contains('niveau 2') || levelLower.contains('niveau2')) {
      return 'medium';
    }
    
    // Si le niveau n'est pas reconnu, utiliser la difficulté par défaut du fichier
    return defaultDifficulty;
  }

  // Normaliser le nom de catégorie (PRÉSERVE les accents français)
  static String _normalizeCategory(String theme) {
    // Simplifier le nom de catégorie tout en préservant les accents français
    // On garde toutes les lettres (y compris accentuées), chiffres et espaces
    // On enlève seulement la ponctuation spécifique
    
    var normalized = theme
        .toLowerCase()
        .replaceAll(RegExp(r'\([^)]*\)'), '') // Enlever les parenthèses et leur contenu
        .trim();
    
    // Remplacer seulement les caractères de ponctuation par rien, mais garder les lettres accentuées
    // Pattern: enlever seulement la ponctuation spécifique, pas les lettres accentuées
    // Garder: lettres (a-z, A-Z, é, è, ê, à, â, ç, ù, û, ô, î, ï, etc.), chiffres (0-9), espaces
    // Utiliser plusieurs replaceAll pour éviter les problèmes d'échappement dans les classes de caractères
    final punctuation = ['.', ',', ';', ':', '!', '?', '-', '_', '=', '+', '*', '&', '%', '\$', '#', '@', '[', ']', '{', '}', '|', '\\', '/', '<', '>', '"', "'", '`', '~'];
    for (final char in punctuation) {
      normalized = normalized.replaceAll(char, '');
    }
    
    // Remplacer les espaces multiples par un seul underscore
    normalized = normalized.replaceAll(RegExp(r'\s+'), '_');
    
    return normalized;
  }

  // Charger les questions par catégorie
  static Future<List<QuestionModel>> loadQuestionsByCategory(String category) async {
    try {
      final allQuestions = await loadQuestions();
      return allQuestions.where((q) => q.category == category).toList();
    } catch (e) {
      debugPrint('❌ LocalDataService: Erreur lors du chargement par catégorie: $e');
      return [];
    }
  }

  // Déterminer la catégorie parente d'un thème (retourne toujours une catégorie)
  static String _getParentCategory(String theme) {
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


  // Générer les catégories dynamiquement depuis les thèmes des fichiers Quiz_Json
  static Future<List<Map<String, dynamic>>> loadCategories() async {
    try {
      debugPrint('📥 LocalDataService: Génération des catégories depuis Quiz_Json...');
      
      // Charger toutes les questions pour extraire les thèmes uniques
      final questions = await loadQuestions();
      
      // Extraire les thèmes uniques et les regrouper par catégorie parente
      final themes = <String, int>{};
      final themesByParent = <String, Map<String, int>>{};
      
      for (final q in questions) {
        final theme = q.category;
        themes[theme] = (themes[theme] ?? 0) + 1;
        
        // Grouper par catégorie parente
        final parent = _getParentCategory(theme);
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

      debugPrint('✅ LocalDataService: ${categories.length} catégories parentes générées');
      return categories;
    } catch (e) {
      debugPrint('❌ LocalDataService: Erreur lors de la génération des catégories: $e');
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

  // Générer une couleur pour chaque catégorie (retourne la valeur hex)
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

  // Obtenir des questions aléatoires
  static Future<List<QuestionModel>> getRandomQuestions({
    int count = 10,
    String? category,
    String? difficulty,
  }) async {
    try {
      var questions = await loadQuestions();
      
      debugPrint('🔍 Filtrage: ${questions.length} questions disponibles');
      debugPrint('   Catégorie recherchée: $category');
      debugPrint('   Difficulté recherchée: $difficulty');
      
      // Filtrer par catégorie si spécifiée
      if (category != null && category.isNotEmpty) {
        final categoryLower = category.toLowerCase().trim();
        final beforeCount = questions.length;
        
        // Extraire la clé de catégorie parente depuis le nom (ex: "🎬 Cinéma" -> "cinema")
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
            final qParent = _getParentCategory(qTheme);
            
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
      debugPrint('❌ LocalDataService: Erreur lors de la récupération de questions aléatoires: $e');
      return [];
    }
  }

  // Réinitialiser le cache (utile pour recharger après modification)
  static void clearCache() {
    _cachedQuestions = null;
  }
}

