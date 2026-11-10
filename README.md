# 🍽️ Préférences Alimentaires Familiales

Application Flutter pour gérer les préférences alimentaires de votre famille.

## Fonctionnalités

- **Familles** : créez une ou plusieurs familles
- **Membres** : ajoutez des membres avec un prénom et un avatar emoji
- **Aliments à éviter** : renseignez les aliments que chaque personne n'apprécie pas
- **Résumé** : vue consolidée de tous les aliments à éviter par famille, avec indication de combien de personnes sont concernées

## Style

Neumorphisme cohérent avec palette bleue douce sur fond gris clair.

## Installation

### Prérequis
- Flutter SDK ≥ 3.10.0
- Dart SDK ≥ 3.0.0

### Étapes

```bash
# 1. Cloner / extraire le projet
cd family_food_app

# 2. Installer les dépendances
flutter pub get

# 3. Lancer l'application
flutter run
```

## Structure du projet

```
lib/
├── main.dart                 # Point d'entrée
├── models/
│   ├── models.dart           # Person, Family
│   └── app_data.dart         # État global + persistance
├── theme/
│   └── app_theme.dart        # Couleurs, ombres, décorations neumorphiques
├── widgets/
│   └── neu_widgets.dart      # Composants réutilisables (NeuCard, NeuButton…)
└── screens/
    ├── home_screen.dart      # Liste des familles
    ├── family_screen.dart    # Membres d'une famille + onglets
    ├── person_screen.dart    # Aliments à éviter d'une personne
    └── summary_screen.dart   # Résumé des aliments à éviter
```

## Dépendances

| Package | Utilisation |
|---------|-------------|
| `provider` | Gestion d'état simple |
| `shared_preferences` | Persistance locale des données |
| `google_fonts` | Police Nunito |
| `uuid` | Génération d'identifiants uniques |
