# Workflow - Tests Mobile VoteClair

## Objectif

Ce workflow sert a creer rapidement des tests Flutter pour les sprints mobile, puis a les valider localement.

## Pre-requis

- Flutter stable installe
- Le dossier `mobile/` a jour
- Les helpers de test partages disponibles dans `mobile/test/helpers/`

## Workflow standard

### 1. Generer un squelette de test

Utiliser le generateur de tests de deputes:

```bash
cd mobile
dart run tool/generate_deputy_test.dart \
  --mode list|details|votes \
  --output test/features/deputies/presentation/pages/new_test.dart \
  --import package:voteclair_mobile/features/deputies/presentation/pages/new_page.dart \
  --widget NewPage \
  --slug jean-dupont
```

Modes disponibles:

- `list` pour un ecran de liste
- `details` pour une fiche detaillee
- `votes` pour un ecran avec pagination, recherche et cartes

### 2. Adapter le squelette

- Remplacer les attentes par les textes et widgets reels du sprint
- Reutiliser `FakeDeputyRepository` et `deputy_fixtures.dart`
- Ajouter les cas loading / error / empty / success
- Garder les interactions utilisateur critiques: navigation, recherche, scroll

### 3. Executer les verifications

```bash
cd mobile
flutter analyze
flutter test
```

### 4. Si le sprint touche une navigation ou une interaction visible

Ajouter au moins un test widget sur le parcours principal:

- ouverture de la page
- action utilisateur principale
- resultat visible a l'ecran

## Regles pratiques

- Un test UI par etat critique est suffisant au debut
- Preferer des tests widget rapides a des tests d'integration lourds
- Ne pas multiplier les assertions cosmetiques
- Ajouter un test de navigation quand un bouton ouvre un nouvel ecran

## Fichiers de base a reutiliser

- [mobile/tool/generate_deputy_test.dart](../../mobile/tool/generate_deputy_test.dart)
- [mobile/test/helpers/fake_deputy_repository.dart](../../mobile/test/helpers/fake_deputy_repository.dart)
- [mobile/test/helpers/deputy_fixtures.dart](../../mobile/test/helpers/deputy_fixtures.dart)

## Validation actuelle

- `flutter analyze` : OK
- `flutter test` : OK
