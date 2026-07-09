# Phase Production 01 - Préparation du projet

## Objectif

Préparer VoteClair à être déployé en production sans impacter l'environnement de développement.

Cette étape ne déploie rien.

Elle prépare uniquement l'architecture du projet afin de supporter plusieurs environnements :

* Développement
* Staging (optionnel)
* Production

---

# Architecture cible

```text
voteclair/

api/
mobile/
docs/

infra/
    docker/
        dev/
        prod/

.github/
    workflows/
```

---

# Objectifs

* Séparer les configurations Docker Dev et Production
* Préparer les variables d'environnement
* Préparer les workflows GitHub Actions
* Préparer les scripts de déploiement
* Préparer la documentation

---

# Docker

Conserver l'environnement actuel.

Créer :

```text
infra/

docker/
    dev/

        Dockerfile

        nginx.conf

    prod/

        Dockerfile

        nginx.conf
```

Le Dockerfile Production devra être indépendant du Dockerfile Dev.

Aucun outil de développement ne devra être installé dans l'image Production.

Exemples :

* Node
* Xdebug
* Composer cache
* dépendances inutiles

---

# docker-compose

Conserver :

docker-compose.yml

Créer :

docker-compose.prod.yml

Ce fichier servira uniquement pour les tests locaux de l'image Production.

---

# Variables d'environnement

Créer :

```text
api/

.env.example

.env.production.example

.env.staging.example
```

Ne jamais versionner :

```text
.env

.env.production

.env.staging
```

---

# Variables attendues

Prévoir les variables suivantes :

Application :

```text
APP_NAME

APP_ENV

APP_KEY

APP_DEBUG

APP_URL
```

Base de données :

```text
DB_CONNECTION

DB_HOST

DB_PORT

DB_DATABASE

DB_USERNAME

DB_PASSWORD
```

Redis :

```text
REDIS_HOST

REDIS_PORT

REDIS_PASSWORD

REDIS_CLIENT
```

Queue :

```text
QUEUE_CONNECTION=redis
```

Cache :

```text
CACHE_STORE=redis
```

Session :

```text
SESSION_DRIVER=database
```

Mail :

Prévoir la configuration SMTP sans l'utiliser immédiatement.

---

# Storage

Prévoir le fonctionnement de :

```bash
php artisan storage:link
```

en production.

---

# Health Check

Créer une route dédiée :

```http
GET /health
```

Réponse :

```json
{
    "status": "ok",
    "version": "1.0.0"
}
```

Cette route sera utilisée plus tard par :

* Render
* UptimeRobot

Elle ne doit nécessiter aucune authentification.

---

# Version

Ajouter un système simple permettant de retourner la version de l'API.

Exemple :

config/app_version.php

ou

config/voteclair.php

avec :

```php
version => "1.0.0-beta"
```

La route /health devra retourner cette version.

---

# Configuration Laravel

Vérifier que :

* APP_DEBUG est désactivable
* APP_ENV est utilisé correctement
* Les logs utilisent stderr en production
* Les caches Laravel fonctionnent

Préparer les commandes :

```bash
php artisan config:cache

php artisan route:cache

php artisan event:cache

php artisan view:cache
```

---

# Scripts

Créer :

```text
scripts/

deploy.sh

optimize.sh
```

deploy.sh

Responsabilités :

* composer install --no-dev
* php artisan migrate --force
* php artisan optimize
* php artisan config:cache
* php artisan route:cache
* php artisan event:cache

optimize.sh

Responsabilités :

* vider les caches
* reconstruire les caches

---

# Documentation

Créer :

```text
docs/deployment/

production.md
```

Documenter :

* architecture
* variables d'environnement
* Docker
* Render
* PostgreSQL
* Redis
* Healthcheck

---

# GitHub

Préparer :

```text
.github/

workflows/
```

Sans créer les workflows pour le moment.

Ils seront réalisés dans la phase suivante.

---

# Contraintes

Le code existant ne doit pas être modifié.

L'environnement Docker de développement doit continuer à fonctionner sans aucune régression.

Aucune donnée de production ne doit être présente dans le dépôt Git.

---

# Critères de validation

À la fin de cette étape :

* l'environnement de développement fonctionne toujours ;
* une structure dédiée à la production existe ;
* les fichiers d'environnement sont prêts ;
* les scripts de déploiement sont créés ;
* l'API expose un endpoint `/health` ;
* la documentation de déploiement est en place ;
* le projet est prêt à accueillir le pipeline CI/CD et le déploiement Render.
