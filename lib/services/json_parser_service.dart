import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Service pour parser et nettoyer les fichiers JSON
/// Gère les problèmes de syntaxe JSON courants dans les fichiers OpenQuizzDB
class JsonParserService {
  /// Parse et nettoie un fichier JSON avec correction des erreurs courantes
  static Map<String, dynamic> parseAndCleanJson(String fileContent) {
    String correctedContent = fileContent;
    
    // 1. Corriger les cas où un retour à la ligne brise une string (PRIORITÉ)
    // Pattern: "texte...\n" -> "texte... " (remplacer le \n par un espace dans la string)
    // Gérer les cas où une string est coupée sur plusieurs lignes
    correctedContent = correctedContent.replaceAllMapped(
      RegExp(r'":\s*"([^"]*?)\r?\n\s*"', multiLine: true),
      (match) {
        final text = match.group(1) ?? '';
        // Remplacer les retours à la ligne par des espaces et nettoyer
        final cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
        return '": "$cleaned"';
      },
    );
    
    // 2. Nettoyer TOUS les caractères de contrôle invalides dans les strings JSON
    // Caractères de contrôle JSON invalides : \x00-\x1F sauf ceux autorisés (\t, \n, \r)
    // Mais on doit les échapper correctement dans les strings
    correctedContent = correctedContent.replaceAllMapped(
      RegExp(r'"(?:[^"\\]|\\.)*"', dotAll: true),
      (match) {
        String str = match.group(0)!;
        // Échapper les caractères de contrôle non déjà échappés dans les strings
        str = str.replaceAllMapped(
          RegExp(r'(?<!\\)[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]'),
          (m) {
            final char = m.group(0)!;
            // Échapper les caractères autorisés en JSON
            if (char == '\n') return '\\n';
            if (char == '\r') return '\\r';
            if (char == '\t') return '\\t';
            // Remplacer les autres caractères de contrôle par un espace
            return ' ';
          },
        );
        return str;
      },
    );
    
    // 3. Nettoyer les caractères de contrôle en dehors des strings (hors guillemets)
    // Pour éviter les problèmes de parsing JSON
    final buffer = StringBuffer();
    bool inString = false;
    bool escaped = false;
    
    for (int i = 0; i < correctedContent.length; i++) {
      final char = correctedContent[i];
      
      if (escaped) {
        buffer.write(char);
        escaped = false;
        continue;
      }
      
      if (char == '\\') {
        escaped = true;
        buffer.write(char);
        continue;
      }
      
      if (char == '"') {
        inString = !inString;
        buffer.write(char);
        continue;
      }
      
      // Si on est dans une string, garder le caractère tel quel
      if (inString) {
        buffer.write(char);
      } else {
        // Si on est hors string, nettoyer les caractères de contrôle
        if (RegExp(r'[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]').hasMatch(char)) {
          // Remplacer par un espace ou supprimer selon le contexte
          if (char == '\n' || char == '\r') {
            buffer.write(' '); // Remplacer les retours à la ligne par un espace
          } else {
            // Supprimer les autres caractères de contrôle
          }
        } else {
          buffer.write(char);
        }
      }
    }
    
    correctedContent = buffer.toString();
    
    try {
      return json.decode(correctedContent) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Erreur lors du parsing JSON après nettoyage: $e');
      rethrow;
    }
  }
}
