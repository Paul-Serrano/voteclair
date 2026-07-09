# CI/CD VoteClair

## Vue d'ensemble

Cette phase met en place une pipeline GitHub Actions pour le backend Laravel de VoteClair et prepare le deploiement automatique sur Render.

Le depot utilise actuellement Laravel 13.8, PHP 8.4, PostgreSQL, Redis et une image Docker de production definie dans `infra/docker/prod/Dockerfile`.

La CI couvre:

- installation PHP 8.4 et extensions requises;
- installation des dependances Composer avec cache;
- preparation Laravel sur PostgreSQL;
- execution des tests;
- verification du style via Laravel Pint;
- analyse statique via Larastan niveau 6;
- build de l'image Docker de production.

Le CD couvre:

- declenchement automatique uniquement apres une CI verte sur `main`;
- appel HTTP POST vers le Deploy Hook Render stocke dans les secrets GitHub.

## Workflows

Les workflows versionnes sont:

- `.github/workflows/ci.yml`
- `.github/workflows/deploy.yml`

Le workflow mobile existant reste independant dans `.github/workflows/mobile-tests.yml`.

## Declenchement

### CI

Le workflow `Backend CI` se lance sur:

- chaque `pull_request`;
- chaque `push` sur `develop`;
- chaque `push` sur `main`.

### Deploy

Le workflow `Deploy Render` se lance via `workflow_run` uniquement lorsque:

- le workflow `Backend CI` a reussi;
- la branche concernee est `main`.

Cela evite la duplication de logique entre CI et deploy.

## Services GitHub Actions

La CI declare deux services:

- PostgreSQL 17
- Redis 8

Variables PostgreSQL utilisees dans la CI:

```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=voteclair_test
DB_USERNAME=postgres
DB_PASSWORD=postgres
```

Variables Redis exposees au job:

```env
REDIS_CLIENT=phpredis
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
```

Les tests utilisent PostgreSQL 17 avec un cache `array` et une queue `sync` pour rester deterministes sur les couches non metier.

La pipeline valide donc de bout en bout:

- le bootstrap Laravel sur PostgreSQL;
- les migrations sur PostgreSQL;
- la suite de tests applicatifs sur PostgreSQL.

## Preparation Laravel

La CI prepare l'application avec les commandes suivantes:

```bash
cp .env.example .env
php artisan key:generate
php artisan migrate --force
php artisan optimize:clear
```

Ensuite la pipeline execute:

```bash
php artisan test
vendor/bin/pint --test
vendor/bin/phpstan analyse --no-progress --memory-limit=1G
```

## Analyse statique

Larastan est installe comme dependance de developpement et configure via:

- `api/phpstan.neon.dist`

Le niveau retenu est `6` et le scope initial couvre:

- `api/app/Providers`
- `api/app/Services/Clair`
- `api/app/Services/Scrutins`
- `api/app/Services/Sync`
- `api/app/Support`

Ce point de depart permet d'introduire une analyse statique stricte sur les briques d'infrastructure, de synchronisation et de scoring sans ouvrir une phase de refactor large sur les annotations generiques Eloquent, les services metier de comparaison/recherche, les commandes console et les resources HTTP deja existantes. La couverture peut etre etendue progressivement dans les phases suivantes.

## Build Docker

La CI verifie l'image de production avec:

```bash
docker build -f infra/docker/prod/Dockerfile -t voteclair-production-ci .
```

L'image n'est pas publiee dans cette phase. Le but est uniquement de valider que le Dockerfile de production reste constructible.

## Deploy Render

Le deploy repose sur un Deploy Hook Render stocke dans les secrets GitHub.

Secret attendu:

```text
RENDER_DEPLOY_HOOK
```

Le workflow `Deploy Render` n'utilise aucune cle API Render et n'ecrit aucun secret dans le depot.

Le job de deploy effectue uniquement:

```bash
curl --fail --silent --show-error --request POST "$RENDER_DEPLOY_HOOK"
```

## README et badges

Le README expose deux badges GitHub Actions:

- `Backend CI`
- `Deploy Render`

Ils pointent vers les workflows `ci.yml` et `deploy.yml` du depot GitHub.

## Secrets GitHub a configurer

Dans les Settings GitHub du depot, ajouter:

- `RENDER_DEPLOY_HOOK`

Ne pas versionner:

- URL complete du hook Render;
- identifiants PostgreSQL ou Redis de production;
- toute cle API externe.

## Sequence attendue

```text
feature/*
    ↓
Pull Request
    ↓
Backend CI
    ↓
Merge develop
    ↓
Backend CI
    ↓
Merge main
    ↓
Backend CI
    ↓
Deploy Render
```

## Evolution prevue

Cette phase prepare la suivante:

- creation des services Render cibles;
- ajout d'un worker et d'un cron dedies;
- choix final de Neon et Upstash si retenus;
- monitoring, alerting et mise en production beta.