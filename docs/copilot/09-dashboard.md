# Sprint 09 - Dashboard d'accueil

## Objectif

Créer la page d'accueil principale de VoteClair.

Cette page doit permettre à un utilisateur d'obtenir immédiatement une vue d'ensemble de l'activité parlementaire récente.

Elle doit devenir le point d'entrée principal de l'application.

---

# Vision Produit

Lorsqu'un utilisateur ouvre VoteClair, il doit immédiatement voir :

* les derniers scrutins
* les statistiques générales
* les groupes parlementaires
* un accès rapide à la recherche

Sans avoir besoin de naviguer.

---

# API Laravel

Créer un endpoint dédié.

```http
GET /api/dashboard
```

---

# DashboardController

Créer :

```php
DashboardController
```

Méthode :

```php
index()
```

---

# Réponse attendue

```json
{
  "stats": {
    "deputies": 577,
    "groups": 11,
    "scrutins": 2543,
    "votes": 1245789
  },

  "latest_scrutins": [],

  "top_groups": [],

  "recent_activity": {
    "last_scrutin_date": "...",
    "last_scrutin_title": "..."
  }
}
```

---

# Statistiques globales

Calculer :

* nombre de députés actifs
* nombre de groupes actifs
* nombre total de scrutins
* nombre total de votes

Utiliser des requêtes optimisées.

---

# Derniers scrutins

Retourner :

```text
10 derniers scrutins
```

Tri :

```sql
date_scrutin DESC
```

Afficher :

* id
* titre
* date
* résultat

---

# Groupes principaux

Retourner :

```text
5 groupes ayant le plus de membres
```

Afficher :

* nom
* couleur
* membres_count

---

# Activité récente

Retourner :

* date du dernier scrutin
* titre du dernier scrutin

---

# Cache

Mettre en cache :

```php
/dashboard
```

pendant :

```text
1 heure
```

Utiliser :

```php
Cache::remember()
```

---

# Resource

Créer :

```php
DashboardResource
```

---

# Flutter

Créer :

```text
features/dashboard/
```

---

# Structure

```text
features/dashboard/

data/
domain/
presentation/

presentation/pages/
    dashboard_page.dart

presentation/widgets/
    dashboard_stats_card.dart
    dashboard_scrutin_tile.dart
    dashboard_group_tile.dart
```

---

# Route

La page d'accueil devient :

```text
/
```

---

# Repository

Créer :

```dart
DashboardRepository
```

Méthode :

```dart
Future<DashboardData> getDashboard();
```

---

# State Management

Créer :

```text
dashboard_provider.dart
```

---

# Header

Afficher :

```text
VoteClair
```

Sous-titre :

```text
Comprendre les votes de vos élus.
```

---

# Barre de recherche

Ajouter un accès rapide :

```text
Rechercher un député, un groupe ou un scrutin
```

Navigation :

```text
/search
```

---

# Section Statistiques

Afficher :

* Députés
* Groupes
* Scrutins
* Votes

Utiliser :

```text
DashboardStatsCard
```

---

# Section Derniers scrutins

Afficher les 10 derniers scrutins.

Créer :

```text
DashboardScrutinTile
```

Informations :

* titre
* date
* résultat

Navigation :

```text
/scrutins/{id}
```

---

# Section Principaux groupes

Afficher :

* logo
* nom
* nombre de membres

Créer :

```text
DashboardGroupTile
```

Navigation :

```text
/groups/{slug}
```

---

# Pull To Refresh

Ajouter :

```dart
RefreshIndicator
```

---

# États

## Loading

Skeleton ou loader.

---

## Error

Afficher :

```text
Impossible de charger les données.
```

Bouton :

```text
Réessayer
```

---

## Success

Afficher toutes les sections.

---

# Design

Utiliser Material 3.

Prévoir :

* Cards
* Responsive
* ScrollView

L'écran doit rester lisible sur smartphone.

---

# Analytics futur

Prévoir une structure extensible permettant d'ajouter :

* scrutins importants
* députés favoris
* alertes
* statistiques personnelles

sans refonte du dashboard.

---

# Critère de validation

L'utilisateur peut :

* voir l'activité récente de l'Assemblée
* consulter les derniers scrutins
* accéder rapidement à la recherche
* accéder aux groupes
* accéder aux scrutins
* rafraîchir les données

Le dashboard devient la page d'accueil officielle de VoteClair.
