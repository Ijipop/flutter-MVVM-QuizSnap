import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_score.dart';
import '../models/quiz_result.dart';
import '../utils/theme.dart';

// Écran de classement
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _selectedTab = 0; // 0: Global, 1: Catégories, 2: Historique

  @override
  void initState() {
    super.initState();
    // Charger les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CLASSEMENT'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final userScore = userProvider.userScore;
          final quizHistory = userProvider.quizHistory;

          // Si pas de données, afficher un message
          if (userScore == null && quizHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Aucune statistique disponible',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complétez des quiz pour voir vos statistiques',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Onglets
              _buildTabs(),
              
              // Contenu selon l'onglet sélectionné
              Expanded(
                child: IndexedStack(
                  index: _selectedTab,
                  children: [
                    _GlobalStatsTab(userScore: userScore, quizHistory: quizHistory),
                    _CategoryStatsTab(userScore: userScore, quizHistory: quizHistory),
                    _HistoryTab(quizHistory: quizHistory),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          _buildTabButton(0, 'GLOBAL', Icons.bar_chart),
          _buildTabButton(1, 'CATÉGORIES', Icons.category),
          _buildTabButton(2, 'HISTORIQUE', Icons.history),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary.withOpacity(0.6),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Onglet Statistiques Globales
class _GlobalStatsTab extends StatelessWidget {
  final UserScore? userScore;
  final List<QuizResult> quizHistory;

  const _GlobalStatsTab({
    required this.userScore,
    required this.quizHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (userScore == null) {
      return const Center(
        child: Text('Aucune statistique disponible'),
      );
    }

    final score = userScore!;
    final totalQuizzes = score.totalQuizzes;
    final totalCorrect = score.totalCorrectAnswers;
    final totalQuestions = score.totalQuestions;
    final accuracy = score.overallAccuracy;
    final bestScore = quizHistory.isNotEmpty
        ? quizHistory.map((r) => r.percentage).reduce((a, b) => a > b ? a : b)
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Carte principale avec score global
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'SCORE GLOBAL',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${accuracy.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Grille de statistiques
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.quiz,
                  label: 'Quiz',
                  value: totalQuizzes.toString(),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle,
                  label: 'Réussites',
                  value: totalCorrect.toString(),
                  color: AppColors.success,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.question_answer,
                  label: 'Questions',
                  value: totalQuestions.toString(),
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.star,
                  label: 'Meilleur Score',
                  value: '${bestScore.toStringAsFixed(0)}%',
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Barre de progression de précision
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRÉCISION GLOBALE',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Stack(
                    children: [
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: accuracy / 100,
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '${accuracy.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Onglet Statistiques par Catégorie
class _CategoryStatsTab extends StatelessWidget {
  final UserScore? userScore;
  final List<QuizResult> quizHistory;

  const _CategoryStatsTab({
    required this.userScore,
    required this.quizHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (userScore == null || userScore!.categoryScores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune statistique par catégorie',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    final score = userScore!;

    // Calculer les meilleures performances par catégorie
    final Map<String, double> categoryBestScores = {};
    final Map<String, int> categoryQuizCount = {};

    for (var result in quizHistory) {
      final category = result.category;
      final percentage = result.percentage;

      if (!categoryBestScores.containsKey(category) ||
          percentage > categoryBestScores[category]!) {
        categoryBestScores[category] = percentage;
      }

      categoryQuizCount[category] = (categoryQuizCount[category] ?? 0) + 1;
    }

    final categoryEntries = score.categoryScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'MEILLEURES PERFORMANCES',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
          ),
          const SizedBox(height: 16),
          ...categoryEntries.map((entry) {
            final category = entry.key;
            final score = entry.value;
            final bestScore = categoryBestScores[category] ?? 0.0;
            final quizCount = categoryQuizCount[category] ?? 0;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            category,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${bestScore.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _CategoryStatItem(
                          icon: Icons.star,
                          label: 'Score Total',
                          value: score.toString(),
                        ),
                        const SizedBox(width: 24),
                        _CategoryStatItem(
                          icon: Icons.quiz,
                          label: 'Quiz',
                          value: quizCount.toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// Onglet Historique
class _HistoryTab extends StatelessWidget {
  final List<QuizResult> quizHistory;

  const _HistoryTab({required this.quizHistory});

  @override
  Widget build(BuildContext context) {
    if (quizHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun historique',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    // Trier par date (plus récent en premier)
    final sortedHistory = List.from(quizHistory)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedHistory.length,
      itemBuilder: (context, index) {
        final result = sortedHistory[index];
        final percentage = result.percentage;
        final date = result.completedAt;

        // Déterminer la couleur selon le score
        Color scoreColor;
        IconData scoreIcon;
        if (percentage >= 80) {
          scoreColor = AppColors.success;
          scoreIcon = Icons.emoji_events;
        } else if (percentage >= 60) {
          scoreColor = Colors.orange;
          scoreIcon = Icons.check_circle;
        } else {
          scoreColor = AppColors.error;
          scoreIcon = Icons.cancel;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: scoreColor,
                  width: 2,
                ),
              ),
              child: Icon(
                scoreIcon,
                color: scoreColor,
              ),
            ),
            title: Text(
              result.category,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  '${result.correctAnswers}/${result.totalQuestions} réponses correctes',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${date.day}/${date.month}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                      ),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: scoreColor,
                  width: 1.5,
                ),
              ),
              child: Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: scoreColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Widget pour une carte de statistique
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Widget pour une statistique de catégorie
class _CategoryStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CategoryStatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }
}
