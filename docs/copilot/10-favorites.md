# Sprint 10 - Favoris

## Objectif

Permettre à un utilisateur de sauvegarder ses députés favoris afin de suivre plus facilement leur activité parlementaire.

Cette fonctionnalité constitue la première forme de personnalisation de VoteClair.

---

# Vision Produit

L'utilisateur doit pouvoir :

* ajouter un député à ses favoris
* retirer un député de ses favoris
* consulter rapidement ses favoris
* accéder à leurs fiches

Les favoris sont stockés localement sur le téléphone.

Aucune authentification n'est requise.

---

# Stockage

Utiliser :

```yaml id="m6d7ke"
shared_preferences
```

---

# Architecture

Créer :

```text id="lbp7m2"
features/favorites/
```

---

# Structure

```text id="z8m1n4"
features/favorites/

data/
domain/
presentation/

presentation/pages/
    favorites_page.dart

presentation/widgets/
    favorite_deputy_tile.dart
```

---

# Service

Créer :

```text id="b7t5wq"
core/storage/favorites_service.dart
```

Responsable :

* sauvegarde
* suppression
* récupération

---

# Données stockées

Conserver uniquement :

```json id="j6r4vx"
[
  "nadege-abomangoli",
  "gabriel-attal",
  "mathilde-panot"
]
```

Stocker uniquement les slugs.

Ne jamais stocker l'objet complet.

---

# API Laravel

Aucune modification backend nécessaire.

Les données sont récupérées à partir des endpoints existants :

```http id="g7n3sp"
GET /api/deputies/{slug}
```

---

# Deputy Details

Modifier :

```text id="x3h7rz"
DeputyDetailsPage
```

---

# Bouton Favori

Ajouter dans l'AppBar :

```text id="1g5ybw"
♡
```

ou :

```text id="v2x0pa"
♥
```

selon l'état.

---

# Comportement

Si le député n'est pas favori :

```text id="jlwmrq"
Ajouter aux favoris
```

---

Si déjà favori :

```text id="ndk3eq"
Retirer des favoris
```

---

# Feedback utilisateur

Afficher :

```text id="smp5jb"
Ajouté aux favoris
```

ou

```text id="ip2d4x"
Retiré des favoris
```

via :

```dart id="5q9e3x"
SnackBar
```

---

# Page Favoris

Créer :

```text id="b9m8wc"
FavoritesPage
```

---

# Route

Ajouter :

```text id="xz7m5d"
/favorites
```

---

# Dashboard

Ajouter une carte :

```text id="t3y9ov"
Mes députés favoris
```

Navigation :

```text id="v1q7df"
/favorites
```

---

# Chargement

Au chargement :

1. récupérer les slugs favoris
2. appeler l'API pour chaque député
3. construire la liste

---

# Affichage

Créer :

```text id="m2f8yz"
FavoriteDeputyTile
```

Afficher :

* photo
* prénom
* nom
* groupe
* présence
* loyauté

---

# Navigation

Un clic ouvre :

```text id="c8n4ew"
/deputies/{slug}
```

---

# États

## Empty

Afficher :

```text id="n5p7as"
Vous n'avez aucun député favori.
```

Message secondaire :

```text id="u7r3mb"
Ajoutez des députés à vos favoris pour les retrouver rapidement.
```

---

## Loading

Loader centré.

---

## Error

Afficher :

```text id="h2q8lv"
Impossible de charger vos favoris.
```

---

## Success

Afficher la liste.

---

# Riverpod

Créer :

```text id="a9f6dk"
favorites_provider.dart
```

Responsable :

* chargement
* ajout
* suppression
* rafraîchissement

---

# Rafraîchissement

Utiliser :

```dart id="r8k4jy"
RefreshIndicator
```

---

# Préparation du futur

Le code doit permettre ultérieurement de remplacer :

```text id="c7p1zr"
SharedPreferences
```

par :

```text id="s4w2ny"
API utilisateur
```

sans modifier l'UI.

Créer une abstraction :

```dart id="m9v5eq"
FavoritesRepository
```

---

# Design

Utiliser Material 3.

Prévoir :

* Cards
* Responsive
* ScrollView

---

# Critère de validation

L'utilisateur peut :

* ajouter un député aux favoris
* retirer un député des favoris
* consulter ses favoris
* accéder rapidement aux fiches
* retrouver ses favoris après fermeture de l'application

Le système fonctionne entièrement hors authentification.
