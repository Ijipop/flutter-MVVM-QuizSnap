# QuizSnap

Application de quiz interactive avec statistiques persistantes.

## 🚀 Démarrage Rapide

### Lancer l'application

**Important pour le Web :** Utilisez un port fixe pour que les statistiques persistent entre les sessions :

```bash
flutter run -d chrome --web-port=8080
```

Ou utilisez le script fourni :
- Windows : `run_web.bat`
- Linux/Mac : `run_web.sh`

### Autres plateformes

```bash
# Android
flutter run -d android

# iOS (sur Mac)
flutter run -d ios
```

## 📊 Persistance des Données

Les statistiques sont sauvegardées automatiquement et persistent entre les sessions.

### ✅ Android & iOS (Production)

**Les utilisateurs sur Android Store et iOS App Store auront leurs progrès sauvegardés !**

- ✅ Persistance garantie entre les sessions
- ✅ Les données survivent aux redémarrages
- ✅ Fonctionne parfaitement en production
- ✅ Utilise le stockage natif du système (SharedPreferences/NSUserDefaults)

### ⚠️ Développement Web

**Note importante pour le développement Web uniquement :** 
- En mode développement, chaque `flutter run` peut utiliser un port différent
- Utilisez `--web-port=8080` pour un port fixe et une persistance garantie
- En production web (même domaine/port), la persistance fonctionne automatiquement

Voir [README_STORAGE.md](README_STORAGE.md) pour plus de détails.

## 🎮 Fonctionnalités

- Quiz par catégorie avec différents niveaux de difficulté
- Statistiques détaillées (scores, historique, classement par catégorie)
- Persistance des données entre les sessions
- Interface moderne avec style Gaming/Néon

## 📚 Ressources

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter Documentation](https://docs.flutter.dev/)
