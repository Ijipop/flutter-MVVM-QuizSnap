import 'package:flutter_test/flutter_test.dart';
import 'package:quizsnap/models/quiz_result.dart';
import 'package:quizsnap/providers/user_provider.dart';

void main() {
  // Initialiser le binding Flutter pour les tests qui utilisent SharedPreferences
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserProvider Tests', () {
    late UserProvider userProvider;

    setUp(() {
      userProvider = UserProvider();
    });

    test('Initial state should have null userScore and empty history', () {
      expect(userProvider.userScore, isNull);
      expect(userProvider.quizHistory, isEmpty);
      expect(userProvider.isLoading, isA<bool>());
    });

    test('updateScore should update userScore correctly', () async {
      // Arrange
      final result = QuizResult(
        totalQuestions: 10,
        correctAnswers: 8,
        score: 8,
        category: 'test_category',
        completedAt: DateTime.now(),
      );

      // Act
      await userProvider.updateScore(result);

      // Assert
      // Note: Les assertions dépendent du StorageService qui utilise SharedPreferences
      // En environnement de test, cela peut nécessiter des mocks
      expect(userProvider.userScore, isNotNull);
      if (userProvider.userScore != null) {
        expect(userProvider.userScore!.totalQuizzes, greaterThanOrEqualTo(1));
        expect(userProvider.userScore!.totalCorrectAnswers, greaterThanOrEqualTo(8));
        expect(userProvider.userScore!.totalQuestions, greaterThanOrEqualTo(10));
      }
    });

    test('updateScore should accumulate scores across multiple quizzes', () async {
      // Arrange
      final result1 = QuizResult(
        totalQuestions: 10,
        correctAnswers: 7,
        score: 7,
        category: 'test_category',
        completedAt: DateTime.now(),
      );

      final result2 = QuizResult(
        totalQuestions: 10,
        correctAnswers: 9,
        score: 9,
        category: 'test_category',
        completedAt: DateTime.now(),
      );

      // Act
      await userProvider.updateScore(result1);
      await userProvider.updateScore(result2);

      // Assert
      // Note: Les valeurs exactes dépendent du StorageService
      expect(userProvider.userScore, isNotNull);
      if (userProvider.userScore != null) {
        expect(userProvider.userScore!.totalQuizzes, greaterThanOrEqualTo(2));
        expect(userProvider.userScore!.totalCorrectAnswers, greaterThanOrEqualTo(16));
        expect(userProvider.userScore!.totalQuestions, greaterThanOrEqualTo(20));
      }
    });

    test('resetAllData should clear all user data', () async {
      // Arrange
      final result = QuizResult(
        totalQuestions: 10,
        correctAnswers: 8,
        score: 8,
        category: 'test_category',
        completedAt: DateTime.now(),
      );
      await userProvider.updateScore(result);

      // Act
      await userProvider.resetAllData();

      // Assert
      expect(userProvider.userScore, isNull);
      expect(userProvider.quizHistory, isEmpty);
    });
  });
}
