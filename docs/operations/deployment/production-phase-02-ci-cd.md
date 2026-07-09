# Phase Production 02 - CI/CD avec GitHub Actions

## Objectif

Mettre en place une intégration continue (CI) et un déploiement continu (CD) pour VoteClair.

Chaque modification poussée sur GitHub devra être automatiquement :

* testée ;
* analysée ;
* construite ;
* puis, si toutes les étapes réussissent, déployée sur Render.

---

# Objectifs

Créer une pipeline GitHub Actions robuste, rapide et maintenable.

Elle devra être compatible avec :

* Laravel 12
* PostgreSQL
* Redis
* Docker
* Render

---

# Arborescence

Créer :

```text
.github/
    workflows/

        ci.yml
        deploy.yml
```

---

# Workflow CI

Déclenchement :

* pull_request
* push sur develop
* push sur main

---

# Étapes

## Checkout

Utiliser la dernière version officielle de :

actions/checkout

---

## PHP

Installer :

* PHP 8.4

avec :

setup-php

Extensions :

* mbstring
* pdo_pgsql
* redis
* bcmath
* intl
* zip

---

## Composer

Installer les dépendances.

Utiliser le cache Composer.

---

## Node

Installer Node uniquement si nécessaire pour le build Flutter Web ou Vite.

Sinon ne pas l'installer.

---

## Base PostgreSQL

Créer un service PostgreSQL dans GitHub Actions.

Version :

17

Créer automatiquement :

* voteclair_test

Variables :

```text
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=voteclair_test
DB_USERNAME=postgres
DB_PASSWORD=postgres
```

---

## Redis

Créer un service Redis.

Variables :

```text
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
```

---

## Laravel

Exécuter :

```bash
cp .env.example .env

php artisan key:generate

php artisan migrate

php artisan optimize:clear
```

---

## Tests

Lancer :

```bash
php artisan test
```

Le pipeline doit échouer si un test échoue.

---

## Qualité

Exécuter :

Laravel Pint

```bash
vendor/bin/pint --test
```

---

## Analyse statique

Installer :

Larastan

Niveau :

6

Exécuter :

```bash
vendor/bin/phpstan analyse
```

---

## Build Docker

Construire l'image Production.

Ne pas publier l'image.

Simple vérification que le Dockerfile est valide.

---

# Workflow Deploy

Déclenchement :

Push sur main uniquement.

---

# Conditions

Le workflow deploy ne doit s'exécuter que si :

* CI réussie
* branche main

---

# Déploiement Render

Utiliser :

Deploy Hook Render

Le webhook sera stocké dans :

GitHub Secrets.

Nom :

```text
RENDER_DEPLOY_HOOK
```

Le workflow devra simplement effectuer un appel HTTP POST vers ce hook.

Aucune clé API Render ne devra être stockée dans le dépôt.

---

# Secrets GitHub

Préparer :

```text
RENDER_DEPLOY_HOOK
```

Aucun secret ne doit être écrit en dur.

---

# Branches

Workflow attendu :

```text
feature/*
        ↓

Pull Request
        ↓

CI
        ↓

Merge develop
        ↓

CI
        ↓

Merge main
        ↓

CI
        ↓

Deploy Render
```

---

# Badges

Ajouter au README :

* Build Passing
* Deploy

---

# Documentation

Créer :

docs/operations/ci-cd.md

Documenter :

* architecture
* fonctionnement
* secrets
* Render
* déploiement

---

# Contraintes

Le pipeline doit être :

* reproductible ;
* rapide ;
* lisible ;
* sans duplication de code ;
* facilement extensible.

---

# Critères de validation

À la fin de cette étape :

* chaque Push déclenche la CI ;
* chaque Pull Request lance les tests ;
* Laravel Pint est exécuté ;
* Larastan est exécuté ;
* les tests passent ;
* l'image Docker est construite avec succès ;
* un Push sur main déclenche automatiquement un déploiement sur Render via un Deploy Hook ;
* toute la configuration est documentée.
