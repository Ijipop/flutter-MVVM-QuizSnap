import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../models/quiz_session_model.dart';
import '../widgets/question_card.dart';
import '../widgets/answer_button.dart';
import '../utils/theme.dart';
import 'result_screen.dart';

// Écran principal du quiz
class QuizScreen extends StatefulWidget {
  final String categoryName;
  final GameMode? gameMode;
  final int? timePerQuestion;
  
  const QuizScreen({
    super.key,
    required this.categoryName,
    this.gameMode,
    this.timePerQuestion,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
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

          // Si le quiz est terminé, rediriger vers les résultats
          if (quizProvider.isQuizComplete) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              quizProvider.finishQuiz(widget.categoryName);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ResultScreen(),
                ),
              );
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
                ...currentQuestion.answers.map((answer) {
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

                // Afficher un message après sélection
                if (userAnswer != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: userAnswer == currentQuestion.correctAnswer
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.error.withOpacity(0.15),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
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
                            child: Text(
                              userAnswer == currentQuestion.correctAnswer
                                  ? 'Bonne réponse !'
                                  : 'Mauvaise réponse. La bonne réponse était: ${currentQuestion.correctAnswer}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
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
                            ? () {
                                if (questionNumber < totalQuestions) {
                                  quizProvider.nextQuestion();
                                } else {
                                  // Dernière question, terminer le quiz
                                  quizProvider.finishQuiz(widget.categoryName);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ResultScreen(),
                                    ),
                                  );
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
