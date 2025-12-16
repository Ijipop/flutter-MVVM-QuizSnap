import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/score_display.dart';
import '../utils/helpers.dart';
import 'home_screen.dart';

// Écran de résultats
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // La sauvegarde est maintenant faite dans quiz_screen.dart avant la navigation
  // Plus besoin de sauvegarder ici pour éviter les boucles infinies

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats'),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          final result = quizProvider.result;

          if (result == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final percentage = result.percentage;
          final message = Helpers.getScoreMessage(percentage);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Message de félicitation
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Icône selon le score
                        Icon(
                          percentage >= 90
                              ? Icons.emoji_events
                              : percentage >= 70
                                  ? Icons.thumb_up
                                  : percentage >= 50
                                      ? Icons.sentiment_satisfied
                                      : Icons.sentiment_dissatisfied,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          message,
                          style: Theme.of(context).textTheme.displayMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Affichage du score
                ScoreDisplay(
                  score: result.correctAnswers,
                  totalQuestions: result.totalQuestions,
                ),

                const SizedBox(height: 24),

                // Détails du résultat
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DÉTAILS',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _ResultRow(
                          label: 'Catégorie',
                          value: result.category,
                        ),
                        const Divider(),
                        _ResultRow(
                          label: 'Bonnes réponses',
                          value: '${result.correctAnswers} / ${result.totalQuestions}',
                        ),
                        const Divider(),
                        _ResultRow(
                          label: 'Pourcentage',
                          value: '${percentage.toStringAsFixed(1)}%',
                        ),
                        const Divider(),
                        _ResultRow(
                          label: 'Date',
                          value: '${result.completedAt.day}/${result.completedAt.month}/${result.completedAt.year}',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Boutons d'action
                ElevatedButton(
                  onPressed: () {
                    // Retourner à l'accueil
                    // La sauvegarde a déjà été faite dans quiz_screen.dart
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'RETOUR À L\'ACCUEIL',
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 16),

                OutlinedButton(
                  onPressed: () {
                    // Réinitialiser et recommencer
                    quizProvider.resetQuiz();
                    Navigator.pop(context);
                  },
                  child: const Text('REFAIRE UN QUIZ'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Widget pour afficher une ligne de résultat
class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
