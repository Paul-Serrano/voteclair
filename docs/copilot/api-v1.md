# VoteClair - API REST V1 Specification

## Objectif

L'objectif de cette première version de l'API est de permettre à l'application mobile Flutter de :

* Consulter les députés
* Consulter les groupes parlementaires
* Consulter les scrutins
* Consulter les votes des députés
* Consulter les votes d'un scrutin

Cette API est **read-only**.

Aucune authentification n'est nécessaire pour le MVP.

---

# Architecture

## Controllers

Créer les controllers suivants :

```text
app/Http/Controllers/Api/

DeputyController
GroupController
ScrutinController
```

---

## Resources

Créer les API Resources suivantes :

```text
app/Http/Resources/

DeputyResource
DeputyCollection

GroupResource

ScrutinResource
ScrutinCollection

VoteResource
VoteCollection
```

Les modèles Eloquent ne doivent jamais être retournés directement.

Toutes les réponses doivent passer par des Resources Laravel.

---

# Routes

## Députés

```php
Route::prefix('deputies')->group(function () {

    Route::get('/', [DeputyController::class, 'index']);

    Route::get('{slug}', [DeputyController::class, 'show']);

    Route::get('{slug}/votes', [DeputyController::class, 'votes']);

});
```

---

## Groupes

```php
Route::get('/groups', [GroupController::class, 'index']);
```

---

## Scrutins

```php
Route::prefix('scrutins')->group(function () {

    Route::get('/', [ScrutinController::class, 'index']);

    Route::get('{scrutin}', [ScrutinController::class, 'show']);

    Route::get('{scrutin}/votes', [ScrutinController::class, 'votes']);

});
```

---

# Endpoint : Liste des députés

## Route

```http
GET /api/deputies
```

## Paramètres

### Recherche

```http
GET /api/deputies?search=attal
```

Recherche sur :

* nom
* prenom

Utiliser PostgreSQL ILIKE.

---

### Filtre par groupe

```http
GET /api/deputies?group=epr
```

Le paramètre correspond au slug du groupe.

---

### Pagination

Utiliser la pagination Laravel standard.

```http
GET /api/deputies?page=1
```

---

## Relations à charger

```php
group
circonscription
```

---

## Réponse

```json
{
  "data": [
    {
      "slug": "gabriel-attal",
      "nom": "Attal",
      "prenom": "Gabriel",
      "photo_url": "...",
      "group": {
        "slug": "epr",
        "nom": "EPR"
      }
    }
  ]
}
```

---

# Endpoint : Fiche député

## Route

```http
GET /api/deputies/{slug}
```

## Recherche

Le slug doit être unique.

Utiliser :

```php
where('slug', $slug)
```

---

## Relations à charger

```php
group
circonscription
```

---

## Réponse

```json
{
  "slug": "gabriel-attal",
  "nom": "Attal",
  "prenom": "Gabriel",
  "profession": "...",
  "photo_url": "...",

  "group": {
    "slug": "epr",
    "nom": "EPR"
  },

  "circonscription": {
    "nom": "Hauts-de-Seine"
  },

  "stats": {
    "presence": 95,
    "loyaute": 98
  },

  "resume_ia": "..."
}
```

---

# Endpoint : Votes d'un député

## Route

```http
GET /api/deputies/{slug}/votes
```

---

## Relations à charger

```php
scrutin
```

---

## Tri

Les votes doivent être triés par date de scrutin décroissante.

Les plus récents en premier.

---

## Pagination

Pagination Laravel.

---

## Réponse

```json
{
  "data": [
    {
      "position": "CONTRE",
      "delegated": false,

      "scrutin": {
        "numero": 7407,
        "titre": "...",
        "date": "2026-06-12"
      }
    }
  ]
}
```

---

# Endpoint : Liste des groupes

## Route

```http
GET /api/groups
```

---

## Tri

Utiliser :

```php
orderBy('ordre')
```

---

## Réponse

```json
{
  "data": [
    {
      "slug": "lfi-nfp",
      "nom": "LFI-NFP",
      "nom_complet": "...",
      "couleur": "#C00D0D",
      "logo_url": "...",
      "position": "GAUCHE"
    }
  ]
}
```

---

# Endpoint : Liste des scrutins

## Route

```http
GET /api/scrutins
```

---

## Paramètres

### Recherche

```http
GET /api/scrutins?search=corse
```

Recherche sur :

```text
titre
```

Utiliser PostgreSQL ILIKE.

---

### Filtre par résultat

```http
GET /api/scrutins?sort=ADOPTE
```

ou

```http
GET /api/scrutins?sort=REJETE
```

---

### Filtre date début

```http
GET /api/scrutins?from=2026-01-01
```

---

### Filtre date fin

```http
GET /api/scrutins?to=2026-06-30
```

---

## Tri

```php
latest('date')
```

---

## Pagination

Pagination Laravel.

---

## Réponse

```json
{
  "data": [
    {
      "id": "...",
      "numero": 7407,
      "date": "2026-06-12",
      "titre": "...",
      "sort": "REJETE"
    }
  ]
}
```

---

# Endpoint : Détail d'un scrutin

## Route

```http
GET /api/scrutins/{id}
```

---

## Réponse

```json
{
  "id": "...",

  "numero": 7407,

  "date": "2026-06-12",

  "titre": "...",

  "sort": "REJETE",

  "resume_ia": "...",

  "demandeur_texte": "...",

  "source_url": "...",

  "dossier": {
    "titre": "...",
    "url": "..."
  }
}
```

---

# Endpoint : Votes d'un scrutin

## Route

```http
GET /api/scrutins/{id}/votes
```

---

## Relations à charger

```php
deputy
```

---

## Pagination

Pagination Laravel.

---

## Réponse

```json
{
  "data": [
    {
      "position": "POUR",

      "delegated": false,

      "deputy": {
        "slug": "gabriel-attal",
        "nom": "Attal",
        "prenom": "Gabriel"
      }
    }
  ]
}
```

---

# Performance

Tous les endpoints doivent :

* Utiliser eager loading (`with()`)
* Éviter les problèmes N+1
* Utiliser la pagination Laravel
* Ne jamais charger des relations inutiles

---

# Validation

Le développement de l'API V1 sera considéré terminé lorsque les endpoints suivants fonctionneront :

```http
GET /api/deputies

GET /api/deputies/{slug}

GET /api/deputies/{slug}/votes

GET /api/groups

GET /api/scrutins

GET /api/scrutins/{id}

GET /api/scrutins/{id}/votes
```

avec des réponses JSON propres utilisant exclusivement des Laravel Resources.
