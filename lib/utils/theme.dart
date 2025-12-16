import 'package:flutter/material.dart';
import 'constants.dart';

// Configuration du thème Gaming/Techno Style Tron (néon doux)
class AppTheme {
  // Thème Gaming - Style moderne avec néons doux
  static ThemeData get lightTheme {
    const primaryColor = Color(AppConstants.primaryColorValue);      // Bleu néon (boutons)
    const secondaryColor = Color(AppConstants.secondaryColorValue);  // Cyan néon (bordures)
    const accentColor = Color(AppConstants.accentColorValue);       // Violet néon (sélections)
    const errorColor = Color(AppConstants.errorColorValue);          // Rouge néon doux
    const backgroundColor = Color(AppConstants.backgroundColorValue); // Fond gris foncé
    const surfaceColor = Color(AppConstants.surfaceColorValue);      // Surface gris moyen

    return ThemeData(
      useMaterial3: true, // Material 3 pour style moderne
      
      // Palette de couleurs Gaming/Techno
      colorScheme: ColorScheme.dark(
        primary: primaryColor,        // Bleu néon
        secondary: secondaryColor,    // Cyan néon
        tertiary: accentColor,        // Violet néon
        error: errorColor,            // Rouge néon doux
        surface: surfaceColor,        // Surface gris moyen
        onPrimary: Colors.white,
        onSecondary: backgroundColor,
        onSurface: Colors.white,
        onError: Colors.white,
        brightness: Brightness.dark,
      ),

      // AppBar style Gaming
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: secondaryColor, // Cyan néon
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: secondaryColor,
          letterSpacing: 1.0,
        ),
        iconTheme: IconThemeData(color: secondaryColor),
      ),

      // Cartes style Gaming avec bordure néon cyan
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: secondaryColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: secondaryColor.withOpacity(0.4), // Cyan néon subtil
            width: 1.5,
          ),
        ),
        color: surfaceColor,
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: 8,
        ),
      ),

      // Boutons style Gaming (bleu néon)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, // Bleu néon
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: primaryColor.withOpacity(0.5), // Ombre néon
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Boutons de texte Gaming
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryColor, // Cyan néon
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Boutons outlined Gaming
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondaryColor, // Cyan néon
          side: BorderSide(color: secondaryColor.withOpacity(0.6), width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Input fields style Gaming
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: secondaryColor.withOpacity(0.4), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: secondaryColor.withOpacity(0.4), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: secondaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        labelStyle: TextStyle(
          color: secondaryColor,
        ),
        hintStyle: TextStyle(
          color: secondaryColor.withOpacity(0.6),
        ),
      ),

      // Floating Action Button Gaming
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
      ),

      // Typographie style Gaming moderne
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white.withOpacity(0.9),
          letterSpacing: 0.2,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white.withOpacity(0.8),
          letterSpacing: 0.2,
        ),
      ),

      // Scaffold background Gaming (gris foncé)
      scaffoldBackgroundColor: backgroundColor,
    );
  }
}

// Couleurs utilitaires pour l'application
class AppColors {
  static const primary = Color(AppConstants.primaryColorValue);
  static const secondary = Color(AppConstants.secondaryColorValue);
  static const accent = Color(AppConstants.accentColorValue);
  static const success = Color(AppConstants.successColorValue);
  static const error = Color(AppConstants.errorColorValue);
}

