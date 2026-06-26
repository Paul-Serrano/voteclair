# VoteClair Mobile

Application Flutter de VoteClair.

Le mobile consomme l'API Laravel du projet pour permettre la consultation rapide des deputes, groupes, scrutins et votes. L'application est construite avec une architecture modulaire autour de `core/` et `features/`.

## Fonctionnalites Disponibles

- tableau de bord avec statistiques et activites recentes;
- recherche globale;
- listes et fiches deputes;
- listes et fiches groupes;
- listes et fiches scrutins;
- page de comparaison entre deux deputes;
- fonctionnalite "trouver mon depute" par code postal;
- favoris et activites liees aux favoris;
- mise en avant des scrutins importants;
- ouverture de liens externes avec fallback Linux.

## Architecture Du Projet

```text
lib/
├── core/
│   ├── api/
│   ├── config/
│   ├── router/
│   ├── services/
│   ├── theme/
│   └── widgets/
└── features/
		├── activity/
		├── comparison/
		├── dashboard/
		├── deputies/
		├── favorites/
		├── find_my_deputy/
		├── groups/
		├── home/
		├── important_votes/
		├── search/
		└── scrutins/
```

## Configuration

L'application utilise notamment:

- `dio` pour les appels HTTP;
- `go_router` pour la navigation;
- `flutter_riverpod` pour l'etat et les repositories;
- `shared_preferences` pour le stockage local;
- `url_launcher` pour l'ouverture de liens externes.

La base URL de l'API est definie dans `lib/core/config/app_config.dart`.

## Lancer L'Application

```bash
cd mobile
flutter pub get
flutter run
```

Si le backend tourne dans Docker, verifier que l'API est joignable depuis la machine qui execute Flutter.

## Tests Et Scaffolding

Un generateur existe pour creer rapidement un squelette de test d'ecran de depute:

```bash
cd mobile
dart run tool/generate_deputy_test.dart \
	--mode list|details|votes \
	--output test/features/deputies/presentation/pages/new_test.dart \
	--import package:voteclair_mobile/features/deputies/presentation/pages/new_page.dart \
	--widget NewPage \
	--slug jean-dupont
```

Le generateur reutilise les fixtures et repositories fakes deja en place dans les tests de sprint.

Le workflow pas a pas est documente dans [../docs/copilot/06-mobile-testing-workflow.md](../docs/copilot/06-mobile-testing-workflow.md).

## Points D'Entree Utiles

- point d'entree Flutter: [lib/main.dart](lib/main.dart)
- navigation: [lib/core/router/app_router.dart](lib/core/router/app_router.dart)
- theme global: [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart)
- client HTTP: [lib/core/api/api_client.dart](lib/core/api/api_client.dart)

## Remarques

- Le dossier `mobile/` contient une base deja structuree, pas un squelette vide.
- Certaines vues peuvent evoluer rapidement selon l'avancement de l'API et des parcours produits.
- Les liens externes sont gérés via un helper commun pour eviter les crashs de lancement sur Linux.
