// Fonctions helper utilitaires
class Helpers {
  // Obtenir un message de félicitation basé sur le score
  static String getScoreMessage(double percentage) {
    if (percentage >= 90) return 'Excellent ! 🎉';
    if (percentage >= 70) return 'Très bien ! 👍';
    if (percentage >= 50) return 'Pas mal ! 😊';
    return 'Continuez vos efforts ! 💪';
  }
}

