import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'category_selection_screen.dart';
import 'leaderboard_screen.dart';
import 'settings_screen.dart';
import '../providers/user_provider.dart';

// Écran principal avec navigation en bas
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Liste des écrans
  final List<Widget> _screens = [
    const HomeContentScreen(),
    const CategorySelectionScreen(),
    const LeaderboardScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Recharger les stats quand on revient sur l'écran Home (index 0)
    if (_currentIndex == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<UserProvider>().loadUserData();
      });
    }
    
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.4), // Cyan néon subtil
              width: 1.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: Theme.of(context).colorScheme.secondary, // Cyan néon
          unselectedItemColor: Theme.of(context)
              .colorScheme
              .secondary
              .withOpacity(0.5),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 0.3,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            letterSpacing: 0.3,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Catégorie',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard),
              label: 'Classement',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

// Contenu de l'écran Home
class HomeContentScreen extends StatefulWidget {
  const HomeContentScreen({super.key});

  @override
  State<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Charger les données utilisateur au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = context.read<UserProvider>();
      // Attendre un peu pour s'assurer que le provider est initialisé
      await Future.delayed(const Duration(milliseconds: 100));
      await userProvider.loadUserData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Recharger les stats quand l'app revient au premier plan
    if (state == AppLifecycleState.resumed) {
      context.read<UserProvider>().loadUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // Titre QuizSnap avec effet néon
            _NeonTitle(text: 'QUIZSNAP'),
            
            const SizedBox(height: 40),
            
            // Bouton Démarrer un Quiz
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategorySelectionScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                minimumSize: const Size(double.infinity, 60),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'DÉMARRER UN QUIZ',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Statistiques rapides
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final userScore = userProvider.userScore;
                final totalQuizzes = userScore?.totalQuizzes ?? 0;
                final totalQuestions = userScore?.totalQuestions ?? 0;
                final totalCorrect = userScore?.totalCorrectAnswers ?? 0;
                final successRate = totalQuestions > 0
                    ? ((totalCorrect / totalQuestions) * 100).round()
                    : 0;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STATISTIQUES',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                              icon: Icons.quiz,
                              label: 'Quiz',
                              value: totalQuizzes.toString(),
                            ),
                            _StatItem(
                              icon: Icons.check_circle,
                              label: 'Réussite',
                              value: '$successRate%',
                            ),
                            _StatItem(
                              icon: Icons.star,
                              label: 'Score',
                              value: totalCorrect.toString(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Derniers résultats
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final history = userProvider.quizHistory;
                final recentResults = history.length > 3
                    ? history.sublist(history.length - 3).reversed.toList()
                    : history.reversed.toList();

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DERNIERS RÉSULTATS',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        if (recentResults.isEmpty)
                          Text(
                            'Aucun quiz complété',
                            style: Theme.of(context).textTheme.bodyMedium,
                          )
                        else
                          ...recentResults.map((result) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            result.category,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${result.correctAnswers}/${result.totalQuestions} - ${result.percentage.toStringAsFixed(0)}%',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      result.percentage >= 70
                                          ? Icons.check_circle
                                          : result.percentage >= 50
                                              ? Icons.check_circle_outline
                                              : Icons.cancel_outlined,
                                      color: result.percentage >= 70
                                          ? Colors.green
                                          : result.percentage >= 50
                                              ? Colors.orange
                                              : Colors.red,
                                    ),
                                  ],
                                ),
                              )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Widget pour afficher une statistique
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

// Widget pour le titre avec effet néon (version simplifiée sans animation pour éviter les erreurs)
class _NeonTitle extends StatelessWidget {
  final String text;

  const _NeonTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ombre néon externe (glow fixe)
        Text(
          text,
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            letterSpacing: 6,
            color: secondaryColor.withOpacity(0.3),
            shadows: [
              Shadow(
                color: secondaryColor.withOpacity(0.6),
                blurRadius: 30,
                offset: const Offset(0, 0),
              ),
              Shadow(
                color: secondaryColor.withOpacity(0.4),
                blurRadius: 50,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
        // Ombre néon interne
        Text(
          text,
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            letterSpacing: 6,
            color: secondaryColor.withOpacity(0.5),
            shadows: [
              Shadow(
                color: secondaryColor,
                blurRadius: 20,
                offset: const Offset(0, 0),
              ),
              Shadow(
                color: secondaryColor.withOpacity(0.8),
                blurRadius: 15,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
        // Texte principal blanc
        Text(
          text,
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            letterSpacing: 6,
            color: Colors.white,
            shadows: [
              Shadow(
                color: secondaryColor.withOpacity(0.8),
                blurRadius: 15,
                offset: const Offset(0, 0),
              ),
              Shadow(
                color: secondaryColor.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
