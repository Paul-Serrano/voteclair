# Sprint 03 - Premier écran métier

## Objectif

Afficher la liste des députés depuis l'API Laravel.

Premier écran réellement connecté aux données.

---

## Endpoint

```http
GET /api/deputies
```

---

## Architecture

Créer :

```text
features/deputies/

data/
domain/
presentation/
```

---

## DTO

Créer les modèles nécessaires.

---

## Repository

Créer :

```text
DeputyRepository
```

responsable des appels API.

---

## State Management

Utiliser Riverpod.

Créer :

```text
deputies_provider.dart
```

---

## Écran

Créer :

```text
DeputiesListPage
```

---

## Affichage

Pour chaque député :

* Photo
* Nom
* Prénom
* Groupe

---

## Gestion des états

Afficher :

### Loading

Indicateur de chargement.

### Error

Message d'erreur.

### Success

Liste scrollable.

---

## Navigation

Un clic sur un député doit préparer la navigation vers :

```text
/deputies/{slug}
```

Même si la fiche n'existe pas encore.

---

## Critère de validation

Les députés sont récupérés depuis l'API Laravel.

La liste s'affiche correctement.
