# Sprint 05 - Historique des votes d'un député

## Objectif

Permettre à un utilisateur de consulter l'ensemble des votes d'un député.

Cet écran constitue la fonctionnalité principale de VoteClair.

L'utilisateur doit pouvoir comprendre rapidement :

* Comment vote un député
* Sur quels sujets il vote
* À quelle fréquence il participe
* Accéder au détail complet d'un scrutin

---

# Endpoint

```http
GET /api/deputies/{slug}/votes
```

---

# Navigation

Depuis :

```text
DeputyDetailsPage
```

Bouton :

```text
Voir les votes
```

Navigation :

```text
/deputies/{slug}/votes
```

---

# Architecture

Créer :

```text
features/deputies/

presentation/pages/
    deputy_votes_page.dart

presentation/widgets/
    vote_card.dart
```

---

# Repository

Réutiliser :

```text
DeputyRepository
```

Ajouter :

```dart
Future<PaginatedVotes> getVotes(
  String slug,
  int page,
);
```

---

# State Management

Créer :

```text
deputy_votes_provider.dart
```

Responsable :

* chargement initial
* pagination
* refresh

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

Lorsqu'on arrive en bas de la liste :

charger automatiquement la page suivante.

---

# Écran

Créer :

```text
DeputyVotesPage
```

---

# Header

Afficher :

* Photo du député
* Nom complet
* Groupe politique

---

# Liste des votes

Chaque vote doit être affiché dans une carte dédiée.

Créer :

```text
VoteCard
```

---

# Contenu d'une carte

Afficher :

## Position

Valeurs possibles :

```text
POUR
CONTRE
ABSTENTION
NON_VOTANT
```

---

## Badge visuel

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

## Informations du scrutin

Afficher :

* titre
* date
* résultat (adopté / rejeté)

---

## Vote délégué

Si :

```text
delegated = true
```

Afficher :

```text
Vote par délégation
```

---

# Recherche locale

Ajouter une SearchBar.

Permettre de filtrer les votes affichés par :

```text
titre du scrutin
```

Le filtrage est local à la liste chargée.

Aucun appel API supplémentaire n'est nécessaire.

---

# Navigation

Un clic sur une carte doit ouvrir :

```text
/scrutins/{id}
```

---

# États

## Loading

Loader centré.

---

## Error

Afficher :

```text
Impossible de charger les votes.
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

Afficher la liste paginée.

---

# Design

Utiliser Material 3.

Prévoir :

* ScrollView
* Infinite Scroll
* Cards
* Espacement cohérent

---

# Critère de validation

L'utilisateur peut :

* consulter les votes d'un député
* voir la position prise sur chaque scrutin
* distinguer visuellement POUR / CONTRE / ABSTENTION
* rechercher dans les votes chargés
* accéder au détail d'un scrutin
* naviguer sans erreur entre les écrans

```
```
