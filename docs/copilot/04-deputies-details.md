# Sprint 04 - Fiche Député

## Objectif

Créer la fiche détaillée d'un député.

Cet écran est central dans VoteClair.

L'utilisateur doit pouvoir comprendre rapidement :

* Qui est le député
* Son groupe politique
* Sa circonscription
* Son activité parlementaire
* Son parcours
* Ses positions
* Accéder à ses votes

---

# Endpoint

```http
GET /api/deputies/{slug}
```

---

# Navigation

Depuis :

```text
DeputiesListPage
```

Lors d'un clic sur un député :

```text
/deputies/{slug}
```

---

# Architecture

Créer :

```text
features/deputies/

data/
domain/
presentation/

presentation/pages/
    deputy_details_page.dart
```

---

# Repository

Réutiliser :

```text
DeputyRepository
```

Ajouter la méthode :

```dart
Future<Deputy> getBySlug(String slug);
```

---

# State Management

Créer un provider Riverpod dédié.

Exemple :

```text
deputy_details_provider.dart
```

Responsable du chargement d'un député.

---

# Écran

Créer :

```text
DeputyDetailsPage
```

---

# Contenu

## Header

Afficher :

* Photo
* Prénom
* Nom
* Groupe politique
* Couleur du groupe

---

## Informations générales

Afficher :

* Profession
* Circonscription
* Département

---

## Réseaux sociaux

Si le champ twitter existe :

Afficher un bouton :

```text
Voir sur X
```

Le bouton doit ouvrir :

```text
https://x.com/{twitter}
```

Utiliser :

```dart
url_launcher
```

Masquer complètement le bouton si aucun compte Twitter/X n'est disponible.

---

# Résumé IA

Titre :

```text
Qui est ce député ?
```

Afficher :

```text
resume_ia
```

---

# Parcours

Titre :

```text
Parcours
```

Afficher :

```text
parcours_ia
```

---

# Positions clés

Titre :

```text
Positions clés
```

Afficher :

```text
positions_cles_ia
```

---

# Faits notables

Titre :

```text
Faits notables
```

Afficher :

```text
faits_notables_ia
```

---

# Statistiques

Créer une section dédiée.

Afficher :

* Présence
* Présence aux scrutins solennels
* Loyauté
* Participation
* Interventions
* Amendements
* Amendements adoptés
* Questions

Utiliser des cartes Material 3.

---

# Appel à l'action

Ajouter un bouton :

```text
Voir les votes
```

Navigation :

```text
/deputies/{slug}/votes
```

Même si cet écran n'est pas encore développé.

---

# États

## Loading

Afficher un loader centré.

---

## Error

Afficher :

```text
Impossible de charger ce député.
```

avec un bouton :

```text
Réessayer
```

---

## Success

Afficher le contenu complet.

---

# Design

Utiliser Material 3.

Prévoir :

* ScrollView
* Responsive
* Espacement cohérent
* Cards pour les statistiques

---

# Critère de validation

La fiche d'un député doit afficher :

* Photo
* Nom
* Groupe
* Profession
* Circonscription
* Compte Twitter/X (si disponible)
* Résumé IA
* Parcours IA
* Positions clés IA
* Faits notables IA
* Statistiques parlementaires

Et permettre la navigation vers les votes du député.
