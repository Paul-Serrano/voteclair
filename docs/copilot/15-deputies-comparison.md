# Sprint 15 - Comparateur de députés

## Objectif

Permettre aux citoyens de comparer les comportements de vote de deux députés.

Cette fonctionnalité doit rendre visibles les convergences et divergences politiques réelles à travers les votes exprimés.

---

# Vision Produit

L'utilisateur sélectionne :

```text
Député A
VS
Député B
```

Et obtient :

```text
Votes communs analysés : 523

Accords : 67 %

Désaccords : 28 %

Abstentions communes : 5 %
```

ainsi que les scrutins où ils ont voté différemment.

---

# API Laravel

Créer :

```http
GET /api/deputies/compare
```

---

# Paramètres

```http
?left_slug=nadege-abomangoli
&right_slug=xavier-albertini
```

---

# Validation

Les deux députés doivent exister.

Retourner :

```http
422
```

si l'un est invalide.

---

# Réponse

```json
{
  "left": {
    "slug": "nadege-abomangoli",
    "nom": "Abomangoli",
    "prenom": "Nadège"
  },

  "right": {
    "slug": "xavier-albertini",
    "nom": "Albertini",
    "prenom": "Xavier"
  },

  "stats": {
    "common_votes": 523,
    "agreements": 352,
    "disagreements": 145,
    "same_abstentions": 26,
    "agreement_rate": 67.3
  },

  "recent_differences": []
}
```

---

# Règles métier

Comparer uniquement les scrutins où :

```text
les deux députés ont voté
```

---

# Matrice de comparaison

Accord :

```text
POUR / POUR
CONTRE / CONTRE
ABSTENTION / ABSTENTION
NON_VOTANT / NON_VOTANT
```

---

# Désaccord

```text
POUR / CONTRE
CONTRE / POUR

POUR / ABSTENTION
ABSTENTION / POUR

CONTRE / ABSTENTION
ABSTENTION / CONTRE
```

---

# Calcul

agreement_rate :

```text
agreements / common_votes * 100
```

---

# Service métier

Créer :

```php
App\Services\Deputies\DeputyComparisonService
```

---

# Méthode

```php
compare(
    Deputy $left,
    Deputy $right
): array
```

---

# Optimisation SQL

Éviter de charger tous les votes en mémoire.

Utiliser :

```sql
JOIN votes
```

sur :

```text
scrutin_id
```

---

# Résultat attendu

Retourner :

```text
100 derniers scrutins communs
```

maximum.

---

# Différences récentes

Retourner :

```json
{
  "scrutin_id": "...",
  "titre": "...",
  "date": "...",

  "left_vote": "POUR",
  "right_vote": "CONTRE"
}
```

---

# Limite

Maximum :

```text
20
```

différences retournées.

---

# Resource

Créer :

```php
DeputyComparisonResource
```

---

# Cache

Mettre en cache :

```text
comparaison A/B
```

pendant :

```text
6 heures
```

---

# Flutter

Créer :

```text
features/comparison/
```

---

# Structure

```text
features/comparison/

data/
domain/
presentation/

presentation/pages/
    comparison_page.dart

presentation/widgets/
    comparison_summary_card.dart
    comparison_difference_tile.dart
```

---

# Repository

Créer :

```dart
ComparisonRepository
```

---

# Méthode

```dart
Future<DeputyComparison> compare(
    String leftSlug,
    String rightSlug,
);
```

---

# Route

Créer :

```text
/compare
```

---

# Sélection

Ajouter :

```text
Député A
Député B
```

avec recherche.

Réutiliser le composant Search existant.

---

# Résumé

Créer :

```text
ComparisonSummaryCard
```

Afficher :

* accords
* désaccords
* taux d'accord
* votes analysés

---

# Visualisation

Créer un indicateur :

```text
0 à 100 %
```

---

# Couleurs

0-25 %

Très opposés

---

25-50 %

Opposés

---

50-75 %

Proches

---

75-100 %

Très proches

---

# Différences récentes

Créer :

```text
ComparisonDifferenceTile
```

Afficher :

* scrutin
* date
* vote A
* vote B

---

# Navigation

Clic :

```text
/scrutins/{id}
```

---

# Dashboard

Ajouter un accès rapide :

```text
Comparer deux députés
```

---

# États

## Loading

Loader.

---

## Error

Afficher :

```text
Impossible de comparer ces députés.
```

---

## Empty

Afficher :

```text
Aucune donnée commune trouvée.
```

---

## Success

Afficher :

* résumé
* score
* différences récentes

---

# Documentation

Créer :

```text
docs/features/deputies-comparison.md
```

---

# Critère de validation

L'utilisateur peut :

* sélectionner deux députés
* obtenir un taux d'accord
* voir les votes communs
* voir les divergences récentes
* accéder aux scrutins concernés

Le calcul doit rester performant même avec plusieurs millions de votes.
