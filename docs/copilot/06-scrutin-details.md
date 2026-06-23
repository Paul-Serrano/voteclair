# Sprint 06 - Détail d'un scrutin

## Objectif

Permettre à un utilisateur de consulter le détail complet d'un scrutin.

Cet écran apporte le contexte nécessaire à la compréhension d'un vote.

L'utilisateur doit pouvoir comprendre :

* De quoi parle le scrutin
* Quand il a eu lieu
* S'il a été adopté ou rejeté
* Qui l'a demandé
* Quel était le résultat global
* Comment les députés ont voté

---

# Endpoints

## Détail du scrutin

```http
GET /api/scrutins/{id}
```

---

## Votes du scrutin

```http
GET /api/scrutins/{id}/votes
```

---

# Navigation

Depuis :

```text
DeputyVotesPage
```

Lors d'un clic sur une carte de vote :

```text
/scrutins/{id}
```

---

# Architecture

Créer :

```text
features/scrutins/

data/
domain/
presentation/

presentation/pages/
    scrutin_details_page.dart

presentation/widgets/
    scrutin_header.dart
    scrutin_result_card.dart
    scrutin_vote_card.dart
```

---

# Repository

Créer ou compléter :

```text
ScrutinRepository
```

Méthodes attendues :

```dart
Future<Scrutin> getById(String id);

Future<PaginatedVotes> getVotes(
  String scrutinId,
  int page,
);
```

---

# State Management

Créer :

```text
scrutin_details_provider.dart
scrutin_votes_provider.dart
```

---

# Écran

Créer :

```text
ScrutinDetailsPage
```

---

# Header

Afficher :

* Numéro du scrutin
* Date
* Institution
* Titre complet

---

# Résultat

Créer une carte dédiée.

Afficher :

```text
Adopté
```

ou

```text
Rejeté
```

selon :

```text
sort
```

---

# Résumé IA

Titre :

```text
Résumé
```

Afficher :

```text
resume_ia
```

---

# Demandeur

Titre :

```text
Qui a demandé ce vote ?
```

Afficher :

```text
demandeur_texte
```

---

# Source officielle

Si :

```text
source_url
```

est présent

Afficher :

```text
Voir la source officielle
```

Ouvrir le navigateur avec :

```dart
url_launcher
```

---

# Résultats globaux

Créer une section dédiée.

Afficher :

* Nombre de POUR
* Nombre de CONTRE
* Nombre d'ABSTENTIONS
* Nombre de NON VOTANTS

Utiliser les champs du scrutin.

---

# Répartition visuelle

Créer une visualisation simple.

Exemple :

```text
POUR          320
███████████

CONTRE        245
████████

ABSTENTION     18
█

NON VOTANT     3
```

Une Progress Indicator Material est suffisante.

---

# Liste des votes

Afficher les votes du scrutin.

Endpoint :

```http
GET /api/scrutins/{id}/votes
```

---

# VoteCard

Afficher :

* Nom du député
* Groupe politique
* Position du vote

---

# Badges

POUR :

```text
🟢 POUR
```

CONTRE :

```text
🔴 CONTRE
```

ABSTENTION :

```text
🟡 ABSTENTION
```

NON_VOTANT :

```text
⚪ NON VOTANT
```

---

# Vote par délégation

Si :

```text
delegated = true
```

Afficher :

```text
Vote par délégation
```

---

# Filtres locaux

Ajouter un filtre :

```text
Tous
POUR
CONTRE
ABSTENTION
NON VOTANT
```

Le filtrage est local.

Aucun appel API supplémentaire.

---

# Recherche locale

Ajouter une SearchBar.

Recherche sur :

* prénom
* nom

Le filtrage est local.

---

# Pagination

Utiliser la pagination Laravel.

Supporter :

```text
page=1
page=2
page=3
```

---

# Infinite Scroll

Charger automatiquement les pages suivantes.

---

# États

## Loading

Loader centré.

---

## Error

Afficher :

```text
Impossible de charger ce scrutin.
```

Bouton :

```text
Réessayer
```

---

## Empty

Afficher :

```text
Aucun vote trouvé.
```

---

## Success

Afficher :

* détail du scrutin
* statistiques
* liste des votes

---

# Design

Utiliser Material 3.

Prévoir :

* ScrollView
* Cards
* Responsive
* Infinite Scroll

---

# Critère de validation

L'utilisateur peut :

* consulter le détail d'un scrutin
* comprendre rapidement le résultat
* lire le résumé IA
* consulter les statistiques globales
* rechercher un député ayant participé
* filtrer les votes
* accéder à la source officielle
* visualiser les votes individuels

```
```
