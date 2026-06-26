# Fondation Flutter

## Objectif

Poser une base Flutter saine pour l'application VoteClair, avec une architecture modulaire, une navigation explicite et un client API centralise.

Cette base ne se limite plus a un simple squelette. Elle sert deja l'application mobile VoteClair avec plusieurs parcours metier.

## Stack

- Flutter stable
- Material 3
- Dio
- GoRouter
- Riverpod
- Shared Preferences
- url_launcher

## Structure Cible

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

main.dart
```

## Architecture Mobile

Le projet suit une separation claire:

- `core/` contient le socle technique partage: client API, configuration, routing, theme et services utilitaires;
- `features/` contient les ecrans, providers, repositories et widgets par domaine metier;
- chaque feature reste orientee cas d'usage plutot qu'autour d'un seul gros dossier transversal.

## Parcours Deja En Place

- dashboard avec statistiques et activite recente;
- recherche globale;
- depotes, groupes et scrutins avec pages de liste et de detail;
- comparaison de deux deputes;
- favoris et activite sur les favoris;
- recherche d'un depute par code postal;
- mise en avant des scrutins importants;
- ouverture de liens externes via un helper compatible Linux.

## API Client

Le client HTTP vit dans `core/api/api_client.dart` et repose sur Dio.

Il sert de point unique pour:

- les appels REST;
- les erreurs reseau;
- les parametres de base URL;
- la reutilisation dans toutes les features.

## Configuration

La configuration centrale se trouve dans `core/config/app_config.dart`.

Le point de configuration principal est la base URL de l'API Laravel.

## Routing

GoRouter est utilise pour la navigation de l'application.

Les routes couvrent notamment:

- l'accueil;
- les listes et fiches deputes;
- les listes et fiches groupes;
- les listes et fiches scrutins;
- la comparaison;
- la recherche;
- la fonctionnalite "trouver mon depute".

## Theme

Le theme global est centralise dans `core/theme/app_theme.dart` avec une approche Material 3.

## Validation Attendue

- l'application demarre sur desktop et mobile;
- la navigation principale fonctionne;
- les repositories sont branches sur le client API;
- les liens externes sont ouverts via le service partage;
- les tests de base sur les ecrans et repositories peuvent etre executes.
