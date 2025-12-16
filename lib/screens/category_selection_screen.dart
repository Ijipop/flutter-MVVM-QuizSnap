import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';
import 'game_mode_selection_screen.dart';
import '../widgets/category_card.dart';

// Écran de sélection de catégorie
class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  String? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    // Charger les catégories au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().loadCategories();
    });
  }

  void _startQuiz(int categoryId, String categoryName) {
    // Debug : vérifier la difficulté avant de passer à l'écran suivant
    
    // Rediriger vers la sélection du mode de jeu avec la difficulté sélectionnée
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameModeSelectionScreen(
          categoryName: categoryName,
          categoryId: categoryId,
          selectedDifficulty: _selectedDifficulty,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir une catégorie'),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          // Afficher un loader pendant le chargement
          if (quizProvider.isLoadingCategories) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    'Récupération des 8000 questions...',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Soyez patient, cela peut prendre quelques instants.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Afficher une erreur si problème
          if (quizProvider.error != null && quizProvider.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      quizProvider.error ?? 'Erreur inconnue',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      quizProvider.loadCategories();
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          // Afficher les catégories
          return Column(
            children: [
              // Sélection de la difficulté
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DIFFICULTÉ',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          children: AppConstants.difficulties.map((difficulty) {
                            final isSelected = _selectedDifficulty == difficulty;
                            return ChoiceChip(
                              label: Text(
                                AppConstants.getDifficultyLabel(difficulty),
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedDifficulty =
                                      selected ? difficulty : null;
                                });
                              },
                              selectedColor:
                                  Theme.of(context).colorScheme.primary,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Liste des catégories
              Expanded(
                child: quizProvider.categories.isEmpty
                    ? Center(
                        child: Text(
                          'Aucune catégorie disponible',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: quizProvider.categories.length,
                        itemBuilder: (context, index) {
                          final category = quizProvider.categories[index];
                          return CategoryCard(
                            categoryName: category.name,
                            questionCount: category.questionCount,
                            onTap: () => _startQuiz(category.id, category.name),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
