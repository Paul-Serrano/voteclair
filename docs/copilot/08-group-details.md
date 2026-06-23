# Sprint 08 - Page Groupe Parlementaire

## Objectif

Permettre à l'utilisateur de consulter les informations détaillées d'un groupe parlementaire.

L'utilisateur doit pouvoir comprendre :

* Qui compose le groupe
* Son positionnement politique
* Son poids à l'Assemblée
* Son activité parlementaire
* Les statistiques globales du groupe

---

# API Laravel

## Endpoint groupe

Créer :

```http
GET /api/groups/{slug}
```

---

## Endpoint membres

Créer :

```http
GET /api/groups/{slug}/deputies
```

---

# Backend

## GroupController

Ajouter :

```php
show(string $slug)

deputies(string $slug)
```

---

## Relations

Charger :

```php
institution
```

pour le groupe.

---

## Réponse groupe

Retourner :

```json
{
  "id": "...",
  "slug": "lfi-nfp",

  "nom": "LFI-NFP",

  "nom_complet": "...",

  "couleur": "#C00D0D",

  "logo_url": "...",

  "position": "GAUCHE",

  "membres_count": 72,

  "stats": {
    "presence": 32,
    "presence_solennelle": 91,
    "loyaute": 99,
    "cohesion": 99,
    "participation": 168139,
    "votes_pour": 82918,
    "votes_contre": 76810,
    "votes_abstention": 8411,
    "votes_absent": 0
  }
}
```

---

## Réponse membres

Retourner :

```json
{
  "data": [
    {
      "slug": "nadege-abomangoli",
      "nom": "Abomangoli",
      "prenom": "Nadège",
      "photo_url": "...",
      "stats_presence": 38
    }
  ]
}
```

---

# Flutter

Créer :

```text
features/groups/
```

---

# Structure

```text
features/groups/

data/
domain/
presentation/

presentation/pages/
    group_details_page.dart

presentation/widgets/
    group_header.dart
    group_stats_card.dart
    group_member_tile.dart
```

---

# Repository

Créer :

```text
GroupRepository
```

Méthodes :

```dart
Future<Group> getBySlug(String slug);

Future<PaginatedDeputies> getDeputies(
  String slug,
  int page,
);
```

---

# Navigation

Ajouter :

```text
/groups/:slug
```

---

# Depuis la recherche

Quand un utilisateur clique sur un groupe :

```text
/groups/{slug}
```

---

# Header

Afficher :

* Logo
* Nom
* Nom complet
* Position politique

---

# Couleurs

Utiliser :

```text
couleur
```

comme couleur principale de l'écran.

---

# Position politique

Afficher un badge :

```text
Extrême gauche
Gauche
Centre gauche
Centre
Centre droit
Droite
Extrême droite
```

à partir de :

```text
position
```

---

# Statistiques

Créer une section dédiée.

Afficher :

* Nombre de membres
* Présence moyenne
* Présence aux scrutins solennels
* Loyauté
* Cohésion
* Participation

---

# Répartition des votes

Afficher :

* Votes POUR
* Votes CONTRE
* Abstentions
* Absents

Créer une visualisation simple.

Utiliser :

* LinearProgressIndicator
* Cards Material 3

---

# Liste des membres

Afficher les députés du groupe.

Créer :

```text
GroupMemberTile
```

Afficher :

* Photo
* Nom
* Prénom
* Présence

---

# Recherche locale

Ajouter une SearchBar.

Recherche sur :

* nom
* prénom

Filtrage local.

---

# Pagination

Utiliser la pagination Laravel.

---

# Infinite Scroll

Charger automatiquement les pages suivantes.

---

# Navigation

Un clic sur un membre ouvre :

```text
/deputies/{slug}
```

---

# États

## Loading

Loader centré.

---

## Error

Afficher :

```text
Impossible de charger ce groupe.
```

Bouton :

```text
Réessayer
```

---

## Empty

Afficher :

```text
Aucun député trouvé.
```

---

## Success

Afficher :

* informations du groupe
* statistiques
* répartition des votes
* liste des membres

---

# Design

Utiliser Material 3.

Prévoir :

* ScrollView
* Responsive
* Infinite Scroll
* Cards

---

# Critère de validation

L'utilisateur peut :

* consulter un groupe parlementaire
* comprendre son positionnement
* consulter ses statistiques
* visualiser sa répartition de votes
* consulter ses membres
* rechercher un membre
* ouvrir la fiche d'un député

```
```
