# Sprint 07 - Recherche globale

## Objectif

Permettre à l'utilisateur de retrouver rapidement :

* un député
* un groupe parlementaire
* un scrutin

depuis une recherche unique.

Cette fonctionnalité doit devenir le principal point d'entrée de l'application.

---

# Vision Produit

Aujourd'hui l'utilisateur navigue :

```text
Liste des députés
    ↓
Fiche député
```

Demain il doit pouvoir écrire :

```text
attal
```

et accéder immédiatement au député.

Ou :

```text
retraites
```

et retrouver les scrutins associés.

---

# API Laravel

Créer un endpoint dédié :

```http
GET /api/search?q=
```

---

# Réponse

Retourner plusieurs catégories :

```json
{
  "deputies": [],
  "groups": [],
  "scrutins": []
}
```

---

# Recherche Députés

Recherche sur :

```text
nom
prenom
nom complet
```

Utiliser PostgreSQL ILIKE.

Limiter :

```text
10 résultats
```

---

# Recherche Groupes

Recherche sur :

```text
nom
nom_complet
slug
```

Limiter :

```text
10 résultats
```

---

# Recherche Scrutins

Recherche sur :

```text
titre
resume_ia
```

Limiter :

```text
20 résultats
```

---

# Controller

Créer :

```text
SearchController
```

Méthode :

```php
search()
```

---

# Resource

Créer :

```text
SearchResource
```

ou DTO équivalent.

---

# Performance

Ne jamais charger :

```php
Vote
```

dans la recherche.

---

# Flutter

Créer :

```text
features/search/
```

---

# Structure

```text
features/search/

data/
domain/
presentation/

presentation/pages/
    search_page.dart

presentation/widgets/
    search_bar.dart
    search_section.dart
    search_result_tile.dart
```

---

# Navigation

Ajouter une route :

```text
/search
```

---

# Accès

Depuis :

```text
HomePage
```

Ajouter :

```text
Rechercher
```

---

# Écran

Créer :

```text
SearchPage
```

---

# Comportement

Champ de recherche en haut.

Placeholder :

```text
Rechercher un député, un groupe ou un scrutin...
```

---

# Debounce

Ajouter un debounce :

```text
500 ms
```

avant l'appel API.

---

# États

## Écran vide

Afficher :

```text
Commencez votre recherche.
```

---

## Loading

Loader.

---

## Aucun résultat

Afficher :

```text
Aucun résultat trouvé.
```

---

## Résultats

Afficher 3 sections.

---

# Section Députés

Afficher :

* photo
* prénom
* nom
* groupe

Navigation :

```text
/deputies/{slug}
```

---

# Section Groupes

Afficher :

* nom
* couleur
* nombre de membres

Navigation future :

```text
/groups/{slug}
```

Même si la page n'existe pas encore.

---

# Section Scrutins

Afficher :

* titre
* date
* résultat

Navigation :

```text
/scrutins/{id}
```

---

# Riverpod

Créer :

```text
search_provider.dart
```

Responsable :

* debounce
* appels API
* états

---

# Repository

Créer :

```text
SearchRepository
```

Méthode :

```dart
Future<SearchResults> search(String query);
```

---

# UX

Le focus doit être mis automatiquement sur le champ de recherche.

Le clavier doit s'ouvrir automatiquement.

---

# Critère de validation

L'utilisateur peut :

* rechercher un député
* rechercher un groupe
* rechercher un scrutin
* naviguer vers une fiche député
* naviguer vers un scrutin
* obtenir des résultats en moins d'une seconde
* utiliser la recherche depuis n'importe quel écran
