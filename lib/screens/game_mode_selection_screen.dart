import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_session_model.dart';
import '../providers/quiz_provider.dart';
import 'quiz_screen.dart';

// Écran de sélection du mode de jeu
class GameModeSelectionScreen extends StatelessWidget {
  final String categoryName;
  final int? categoryId;
  final String? selectedDifficulty;

  const GameModeSelectionScreen({
    super.key,
    required this.categoryName,
    this.categoryId,
    this.selectedDifficulty,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mode de jeu - $categoryName'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'CHOISISSEZ VOTRE MODE',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Mode Rapide
            _GameModeCard(
              title: 'Mode Rapide',
              description: '10 questions, 15 secondes chacune',
              icon: Icons.flash_on,
              color: Colors.orange,
              onTap: () => _startGame(context, GameMode.quick, 10, 15),
            ),
            
            const SizedBox(height: 16),
            
            // Mode Marathon
            _GameModeCard(
              title: 'Mode Marathon',
              description: '50 questions, testez votre endurance',
              icon: Icons.directions_run,
              color: Colors.purple,
              onTap: () => _startGame(context, GameMode.marathon, 50, 30),
            ),
            
            const SizedBox(height: 16),
            
            // Mode Survie
            _GameModeCard(
              title: 'Mode Survie',
              description: 'Jusqu\'à la première erreur, 5 vies',
              icon: Icons.favorite,
              color: Colors.red,
              onTap: () => _startGame(context, GameMode.survival, 100, 20),
            ),
            
            const SizedBox(height: 16),
            
            // Mode Défi Quotidien
            _GameModeCard(
              title: 'Défi Quotidien',
              description: 'Un nouveau défi chaque jour',
              icon: Icons.calendar_today,
              color: Colors.blue,
              onTap: () => _startGame(context, GameMode.daily, 15, 20),
            ),
            
            const SizedBox(height: 16),
            
            // Mode Personnalisé
            _GameModeCard(
              title: 'Mode Personnalisé',
              description: 'Choisissez vos paramètres',
              icon: Icons.settings,
              color: Colors.grey,
              onTap: () => _showCustomModeDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _startGame(
    BuildContext context,
    GameMode mode,
    int questionCount,
    int timePerQuestion,
  ) async {
    final quizProvider = context.read<QuizProvider>();
    
    // Charger les questions selon le mode avec la difficulté sélectionnée
    await quizProvider.loadQuestions(
      amount: questionCount,
      category: categoryId,
      difficulty: selectedDifficulty, // Passer la difficulté sélectionnée
    );

    if (quizProvider.error != null && quizProvider.questions.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${quizProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(
            categoryName: categoryName,
            gameMode: mode,
            timePerQuestion: timePerQuestion,
          ),
        ),
      );
    }
  }

  void _showCustomModeDialog(BuildContext context) {
    int questionCount = 10;
    int timePerQuestion = 20;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mode Personnalisé'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nombre de questions: $questionCount'),
            Slider(
              value: questionCount.toDouble(),
              min: 5,
              max: 50,
              divisions: 9,
              label: questionCount.toString(),
              onChanged: (value) {
                questionCount = value.toInt();
              },
            ),
            const SizedBox(height: 16),
            Text('Temps par question: $timePerQuestion secondes'),
            Slider(
              value: timePerQuestion.toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              label: '$timePerQuestion s',
              onChanged: (value) {
                timePerQuestion = value.toInt();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame(context, GameMode.custom, questionCount, timePerQuestion);
            },
            child: const Text('Commencer'),
          ),
        ],
      ),
    );
  }
}

// Carte pour un mode de jeu
class _GameModeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GameModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}

