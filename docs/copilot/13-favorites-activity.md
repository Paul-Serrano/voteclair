# Sprint 13 - Activité de mes députés favoris

## Objectif

Permettre à l'utilisateur de suivre l'activité récente de ses députés favoris.

Cette fonctionnalité constitue la première étape vers un système d'alertes et de notifications.

---

# Vision Produit

Aujourd'hui :

```text id="wn9ch5"
Favoris
 ├── Attal
 ├── Panot
 └── Abomangoli
```

Demain :

```text id="mpgld7"
Activité récente

🟢 Gabriel Attal
A voté POUR le projet de loi X

🔴 Mathilde Panot
A voté CONTRE le projet de loi Y

🟡 Nadège Abomangoli
S'est abstenue sur le scrutin Z
```

---

# Principe

Utiliser les favoris existants.

Aucune authentification.

Aucune notification push.

Les données sont calculées dynamiquement.

---

# API Laravel

Créer :

```http id="v8fdwm"
GET /api/favorites/activity
```

---

# Paramètre

```http id="pwgfca"
?slugs=attal,panot,...
```

---

# Exemple

```http id="myyw2e"
GET /api/favorites/activity?slugs=nadege-abomangoli,xavier-albertini
```

---

# Réponse

```json id="9efjzi"
{
  "data": [
    {
      "deputy": {
        "slug": "nadege-abomangoli",
        "nom": "Abomangoli",
        "prenom": "Nadège",
        "photo_url": "..."
      },

      "latest_vote": {
        "id": "...",
        "position": "POUR",
        "scrutin": {
          "id": "...",
          "titre": "...",
          "date": "..."
        }
      }
    }
  ]
}
```

---

# Controller

Créer :

```php id="bd0th6"
FavoriteActivityController
```

---

# Endpoint

Ajouter :

```php id="59fuwc"
GET /api/favorites/activity
```

---

# Règles métier

Pour chaque député :

Récupérer :

```text id="8j4a05"
dernier vote connu
```

Tri :

```sql id="owh9sp"
vote_date DESC
```

---

# Optimisation

Utiliser :

```php id="vlt4rn"
eager loading
```

---

Éviter les N+1.

---

# Resource

Créer :

```php id="a3w92i"
FavoriteActivityResource
```

---

# Flutter

Créer :

```text id="km1fdg"
features/activity/
```

---

# Structure

```text id="73yxb7"
features/activity/

data/
domain/
presentation/

presentation/pages/
    favorites_activity_page.dart

presentation/widgets/
    activity_card.dart
```

---

# Repository

Créer :

```dart id="0gck1z"
ActivityRepository
```

Méthode :

```dart id="wn9i6e"
Future<List<ActivityItem>> getFavoritesActivity(
  List<String> slugs,
);
```

---

# Dashboard

Ajouter une nouvelle section.

Titre :

```text id="1m0e1r"
Activité de mes favoris
```

---

# Limite

Afficher :

```text id="i8vlk4"
5 activités
```

maximum.

---

# ActivityCard

Afficher :

* photo député
* nom
* position du vote
* titre du scrutin
* date

---

# Badges

POUR :

```text id="ghukn0"
🟢 POUR
```

---

CONTRE :

```text id="ah5j3o"
🔴 CONTRE
```

---

ABSTENTION :

```text id="e5w3q8"
🟡 ABSTENTION
```

---

NON_VOTANT :

```text id="7k7mdv"
⚪ NON VOTANT
```

---

# Navigation

Clic sur activité :

```text id="5w5s2l"
/scrutins/{id}
```

---

# États

## Aucun favori

Afficher :

```text id="v9sqcp"
Ajoutez des députés à vos favoris pour suivre leur activité.
```

---

## Aucun vote

Afficher :

```text id="2dntsk"
Aucune activité récente trouvée.
```

---

## Loading

Loader.

---

## Error

Afficher :

```text id="6s9fxd"
Impossible de charger l'activité.
```

---

## Success

Afficher la liste.

---

# Refresh

Supporter :

```dart id="r7um8i"
RefreshIndicator
```

---

# Préparation Sprint 14

Prévoir une architecture permettant plus tard :

```text id="jlwmpr"
Nouveau scrutin important
Nouvelle activité d'un favori
Notification push
```

sans refonte.

---

# Critère de validation

L'utilisateur peut :

* consulter l'activité récente de ses favoris
* voir leur dernier vote
* accéder au scrutin associé
* retrouver cette activité depuis le dashboard

La fonctionnalité fonctionne sans authentification.
