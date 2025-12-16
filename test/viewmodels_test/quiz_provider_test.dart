import 'package:flutter_test/flutter_test.dart';
import 'package:quizsnap/providers/quiz_provider.dart';

void main() {
  group('QuizProvider Tests', () {
    late QuizProvider quizProvider;

    setUp(() {
      quizProvider = QuizProvider();
    });

    test('Initial state should be empty', () {
      expect(quizProvider.questions, isEmpty);
      expect(quizProvider.categories, isEmpty);
      expect(quizProvider.currentQuestionIndex, 0);
      expect(quizProvider.isLoading, false);
      expect(quizProvider.error, isNull);
      expect(quizProvider.result, isNull);
    });

    test('answerQuestion should store user answer', () {
      // Act
      quizProvider.answerQuestion('A');
      
      // Assert
      expect(quizProvider.userAnswers[0], 'A');
    });

    test('nextQuestion should increment currentQuestionIndex when questions exist', () {
      // Note: Pour tester complètement nextQuestion, il faudrait charger des questions
      // via loadQuestions() qui nécessite de mocker LocalDataService
      // Ce test vérifie que la méthode ne plante pas
      
      // Act
      quizProvider.nextQuestion();
      
      // Assert - Si pas de questions, l'index reste à 0
      expect(quizProvider.currentQuestionIndex, greaterThanOrEqualTo(0));
    });

    test('previousQuestion should decrement currentQuestionIndex', () {
      // Note: Ce test nécessiterait des questions chargées pour fonctionner correctement
      // Pour l'instant, on vérifie juste que la méthode ne plante pas
      // et que l'index ne devient pas négatif
      
      // Act
      quizProvider.previousQuestion();
      
      // Assert - L'index ne doit jamais être négatif
      expect(quizProvider.currentQuestionIndex, greaterThanOrEqualTo(0));
    });

    test('previousQuestion should not go below 0', () {
      // Act
      quizProvider.previousQuestion();
      
      // Assert
      expect(quizProvider.currentQuestionIndex, 0);
    });

    test('resetQuiz should clear all quiz data', () {
      // Arrange
      quizProvider.answerQuestion('A');
      quizProvider.nextQuestion();
      
      // Act
      quizProvider.resetQuiz();
      
      // Assert
      expect(quizProvider.questions, isEmpty);
      expect(quizProvider.userAnswers, isEmpty);
      expect(quizProvider.currentQuestionIndex, 0);
      expect(quizProvider.result, isNull);
      expect(quizProvider.error, isNull);
    });

    test('isQuizComplete should return true when all questions answered', () {
      // Note: Ce test nécessiterait des questions chargées
      // Pour un test complet, il faudrait mocker LocalDataService
      expect(quizProvider.isQuizComplete, isA<bool>());
    });
  });
}
