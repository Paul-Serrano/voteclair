# Sprint 14 - Votes importants

## Objectif

Mettre en avant les scrutins les plus significatifs pour les citoyens.

Tous les scrutins n'ont pas la même importance.

VoteClair doit être capable d'identifier automatiquement les votes majeurs et de les afficher en priorité.

---

# Vision Produit

Aujourd'hui :

```text id="m6s1xk"
Derniers scrutins

- Scrutin 4587
- Scrutin 4586
- Scrutin 4585
```

Demain :

```text id="2c6j6o"
🔥 Votes importants

Motion de censure

Budget 2027

Réforme des retraites

Loi immigration
```

---

# Nouvelle colonne

Ajouter dans :

```sql id="8i3fwl"
scrutins
```

---

```sql id="gj9i5r"
importance_score INTEGER NOT NULL DEFAULT 0
```

---

# Migration

Créer une migration dédiée.

Ne pas recalculer tous les scrutins dans la migration.

---

# Service métier

Créer :

```php id="o9u8gc"
App\Services\Scrutins\ImportanceScoringService
```

---

# Responsabilité

Calculer :

```text id="1fbb0j"
importance_score
```

pour chaque scrutin.

---

# Méthode

```php id="61u6qe"
calculate(Scrutin $scrutin): int
```

---

# Règles V1

## Scrutin solennel

```text id="wly8uv"
+50
```

---

## Motion de censure

Titre contient :

```text id="ij6o6m"
censure
```

```text id="o5xq49"
+100
```

---

## Loi de finances

Titre contient :

```text id="1sj2zf"
finances
budget
```

```text id="i3h4rv"
+80
```

---

## Retraites

Titre contient :

```text id="s7pjsm"
retraites
```

```text id="84a4n0"
+70
```

---

## Immigration

Titre contient :

```text id="ql0q2o"
immigration
```

```text id="f8vg4x"
+70
```

---

## Constitution

Titre contient :

```text id="8b6l1v"
constitution
constitutionnelle
```

```text id="r5k5rl"
+90
```

---

## Participation élevée

Si :

```text id="m79ox8"
votes_exprimes > 500
```

```text id="w1rk4m"
+20
```

---

## Résultat serré

Si :

```text id="8s4vly"
écart < 20 voix
```

```text id="y5l2ki"
+30
```

---

# Commande

Créer :

```bash id="bbh57j"
php artisan voteclair:recalculate-importance
```

---

# Classe

```php id="ddh6z4"
RecalculateImportanceCommand
```

---

# Utilisation

```bash id="81op4w"
php artisan voteclair:recalculate-importance
```

---

# Synchronisation

À la fin :

```php id="z71b4h"
SyncScrutinsJob
```

recalculer automatiquement :

```text id="efc29u"
importance_score
```

pour les nouveaux scrutins.

---

# API Laravel

Créer :

```http id="13fwy4"
GET /api/scrutins/important
```

---

# Paramètres

Optionnels :

```http id="5d0jhm"
?limit=20
```

---

# Réponse

Retourner :

```json id="y8i29u"
{
  "data": [
    {
      "id": "...",
      "titre": "...",
      "date_scrutin": "...",
      "importance_score": 170
    }
  ]
}
```

---

# Tri

Toujours :

```sql id="orv9dx"
importance_score DESC
```

---

# Controller

Créer :

```php id="6e4blv"
ImportantScrutinController
```

---

# Resource

Créer :

```php id="s4cyxg"
ImportantScrutinResource
```

---

# Flutter

Créer :

```text id="7jlwmk"
features/important_votes/
```

---

# Repository

Créer :

```dart id="k1bb5w"
ImportantVotesRepository
```

---

# Méthode

```dart id="evnjs5"
Future<List<Scrutin>> getImportantVotes();
```

---

# Dashboard

Ajouter une section.

Titre :

```text id="0d6jrd"
🔥 Votes importants
```

---

# Limite

Afficher :

```text id="xvsvyl"
5
```

scrutins maximum.

---

# Widget

Créer :

```text id="w0s6yr"
ImportantVoteCard
```

---

# Affichage

* titre
* date
* score
* résultat

---

# Navigation

Clic :

```text id="b4qqgv"
/scrutins/{id}
```

---

# Badges

Afficher :

```text id="q4v2t8"
Très important
```

si :

```text id="v4i7au"
score >= 150
```

---

Afficher :

```text id="a3n7f4"
Important
```

si :

```text id="40rq5x"
score >= 100
```

---

# États

## Loading

Loader.

---

## Error

Afficher :

```text id="x07d4e"
Impossible de charger les votes importants.
```

---

## Empty

Afficher :

```text id="0xv8eq"
Aucun scrutin important trouvé.
```

---

## Success

Afficher les cartes.

---

# Cache

Mettre en cache :

```php id="8ukz3z"
/api/scrutins/important
```

pendant :

```text id="b25k6m"
1 heure
```

---

# Documentation

Créer :

```text id="jlwmv6"
docs/features/important-votes.md
```

Documenter :

* calcul du score
* critères
* recalcul
* API

---

# Critère de validation

VoteClair doit pouvoir :

* identifier automatiquement les scrutins importants
* afficher ces scrutins sur le dashboard
* recalculer les scores
* exposer les données via l'API
* mettre en avant les sujets majeurs pour les citoyens
