import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/user_provider.dart';
import '../models/game_mode.dart';
import '../widgets/question_card.dart';
import '../widgets/answer_button.dart';
import '../utils/theme.dart';
import 'result_screen.dart';

// Écran principal du quiz
class QuizScreen extends StatefulWidget {
  final String categoryName;
  final GameMode? gameMode;
  
  const QuizScreen({
    super.key,
    required this.categoryName,
    this.gameMode,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _hasInitiatedFinish = false; // Flag pour éviter les appels multiples à finishQuiz

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          // Afficher un loader pendant le chargement
          if (quizProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Afficher une erreur si problème
          if (quizProvider.error != null && quizProvider.questions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                        Navigator.pop(context);
                      },
                      child: const Text('Retour'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Si le quiz est terminé, sauvegarder et rediriger vers les résultats
          if (quizProvider.isQuizComplete && !_hasInitiatedFinish) {
            _hasInitiatedFinish = true;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!mounted) return;
              
              // Terminer le quiz et créer le résultat
              quizProvider.finishQuiz(widget.categoryName);
              
              // Attendre un peu pour s'assurer que le résultat est créé
              await Future.delayed(const Duration(milliseconds: 100));
              
              // Sauvegarder le résultat immédiatement avant de naviguer
              final result = quizProvider.result;
              if (result != null && mounted) {
                try {
                  final userProvider = context.read<UserProvider>();
                  await userProvider.updateScore(result);
                } catch (e) {
                  debugPrint('QuizScreen: Erreur lors de la sauvegarde: $e');
                  // Continuer même en cas d'erreur
                }
              }
              
              // Naviguer vers l'écran de résultats
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResultScreen(),
                  ),
                );
              }
            });
            return const Center(child: CircularProgressIndicator());
          }

          // Afficher la question actuelle
          final currentQuestion = quizProvider.currentQuestion;
          if (currentQuestion == null) {
            return const Center(
              child: Text('Aucune question disponible'),
            );
          }

          final questionNumber = quizProvider.currentQuestionIndex + 1;
          final totalQuestions = quizProvider.questions.length;
          final userAnswer = quizProvider.userAnswers[quizProvider.currentQuestionIndex];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Afficher les vies en mode survie
                if (quizProvider.gameMode == GameMode.survival) ...[
                  Card(
                    color: quizProvider.lives <= 1
                        ? AppColors.error.withOpacity(0.2)
                        : Colors.red.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.favorite, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'Vies: ${quizProvider.lives} / 5',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: quizProvider.lives <= 1 ? AppColors.error : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Barre de progression
                LinearProgressIndicator(
                  value: questionNumber / totalQuestions,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // Carte de question
                QuestionCard(
                  question: currentQuestion.question,
                  questionNumber: questionNumber,
                  totalQuestions: totalQuestions,
                ),

                const SizedBox(height: 24),

                // Titre des réponses
                Text(
                  'RÉPONSES',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Liste des réponses
                ...currentQuestion.options.map((answer) {
                  final isSelected = userAnswer == answer;
                  final isCorrect = answer == currentQuestion.correctAnswer;
                  // Afficher le résultat si une réponse a été sélectionnée
                  final showResult = userAnswer != null;
                  
                  return AnswerButton(
                    answer: answer,
                    onTap: userAnswer == null
                        ? () {
                            quizProvider.answerQuestion(answer);
                          }
                        : () {
                            // Ne rien faire si déjà sélectionné
                          },
                    isSelected: isSelected,
                    isCorrect: isCorrect,
                    showResult: showResult,
                  );
                }),

                // Afficher un message après sélection avec anecdote
                if (userAnswer != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: userAnswer == currentQuestion.correctAnswer
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.error.withOpacity(0.15),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                userAnswer == currentQuestion.correctAnswer
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: userAnswer == currentQuestion.correctAnswer
                                    ? AppColors.success
                                    : AppColors.error,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userAnswer == currentQuestion.correctAnswer
                                          ? 'Bonne réponse !'
                                          : 'Mauvaise réponse. La bonne réponse était: ${currentQuestion.correctAnswer}',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    // Afficher un message spécial en mode survie si on perd une vie
                                    if (quizProvider.gameMode == GameMode.survival &&
                                        userAnswer != currentQuestion.correctAnswer) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        quizProvider.lives <= 0
                                            ? '💔 Plus de vies ! Le jeu est terminé.'
                                            : '💔 Vous avez perdu une vie. Vies restantes: ${quizProvider.lives}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // Afficher l'anecdote si elle existe
                          if (currentQuestion.explanation.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Le saviez-vous ?',
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        currentQuestion.explanation,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Boutons de navigation
                Row(
                  children: [
                    // Bouton précédent
                    if (quizProvider.currentQuestionIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            quizProvider.previousQuestion();
                          },
                          child: const Text('PRÉCÉDENT'),
                        ),
                      ),
                    if (quizProvider.currentQuestionIndex > 0)
                      const SizedBox(width: 16),

                    // Bouton suivant/terminer
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: userAnswer != null
                            ? () async {
                                if (questionNumber < totalQuestions) {
                                  quizProvider.nextQuestion();
                                } else {
                                  // Dernière question, terminer le quiz
                                  quizProvider.finishQuiz(widget.categoryName);
                                  
                                  // Sauvegarder le résultat avant de naviguer
                                  final result = quizProvider.result;
                                  if (result != null && context.mounted) {
                                    try {
                                      final userProvider = context.read<UserProvider>();
                                      await userProvider.updateScore(result);
                                      debugPrint('✅ QuizScreen: Résultat sauvegardé avant navigation');
                                    } catch (e) {
                                      debugPrint('❌ QuizScreen: Erreur lors de la sauvegarde: $e');
                                    }
                                  }
                                  
                                  // Naviguer vers l'écran de résultats
                                  if (context.mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ResultScreen(),
                                      ),
                                    );
                                  }
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          questionNumber < totalQuestions
                              ? 'SUIVANT'
                              : 'TERMINER',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Indicateur de progression
                Center(
                  child: Text(
                    '$questionNumber / $totalQuestions',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
