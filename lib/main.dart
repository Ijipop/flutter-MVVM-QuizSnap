import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'utils/theme.dart';
import 'providers/quiz_provider.dart';
import 'providers/user_provider.dart';
import 'providers/timer_provider.dart';
import 'providers/stats_provider.dart';
import 'screens/home_screen.dart';

void main() {
  debugPrint('🚀 QuizSnap: Démarrage de l\'application');
  runApp(const QuizSnapApp());
}

class QuizSnapApp extends StatelessWidget {
  const QuizSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ QuizSnap: Création des providers');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          debugPrint('📦 QuizSnap: Création du QuizProvider');
          return QuizProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          debugPrint('📦 QuizSnap: Création du UserProvider');
          // Le UserProvider charge automatiquement les données dans son constructeur
          return UserProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          debugPrint('📦 QuizSnap: Création du TimerProvider');
          return TimerProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          debugPrint('📦 QuizSnap: Création du StatsProvider');
          final provider = StatsProvider();
          // Charger les stats au démarrage
          provider.loadStats();
          return provider;
        }),
      ],
      child: MaterialApp(
        title: 'QuizSnap',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light, // Changez en ThemeMode.dark pour tester le mode sombre
        home: const HomeScreen(),
      ),
    );
  }
}
