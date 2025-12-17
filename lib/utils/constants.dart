// Constantes de l'application
class AppConstants {
  // Couleurs Gaming/Techno Style Tron (néon doux)
  static const int primaryColorValue = 0xFF008CFF;      // Bleu néon (boutons)
  static const int secondaryColorValue = 0xFF00F5FF;    // Cyan néon (bordures)
  static const int accentColorValue = 0xFFBC5BFF;      // Violet néon (sélections)
  static const int successColorValue = 0xFF00F5FF;     // Cyan succès
  static const int errorColorValue = 0xFFFF4D4D;       // Rouge néon doux
  static const int backgroundColorValue = 0xFF181A1F;  // Fond gris foncé
  static const int surfaceColorValue = 0xFF232529;     // Surface gris moyen
  
  // Tailles
  static const double defaultPadding = 16.0;
  
  // Difficultés supportées
  // - 'easy' → Facile
  // - 'medium' → Moyen  
  // - 'hard' → Difficile
  static const List<String> difficulties = ['easy', 'medium', 'hard'];
  
  // Traductions des difficultés pour l'affichage en français
  static String getDifficultyLabel(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 'Facile';
      case 'medium':
        return 'Moyen';
      case 'hard':
        return 'Difficile';
      default:
        return difficulty;
    }
  }
  
}

