# Deploiement production VoteClair

## Vue d'ensemble

Cette phase prepare VoteClair pour un deploiement futur sur Render sans modifier le cycle de developpement actuel.

L'environnement local existant continue d'utiliser [docker-compose.yml](../../docker-compose.yml) et [docker/php/Dockerfile](../../docker/php/Dockerfile).

La preparation production ajoute:

- une arborescence Docker dediee sous `infra/docker`;
- une image de production independante du dev;
- un compose local pour tester l'image de production;
- des gabarits d'environnement pour staging et production;
- des scripts de deploiement et d'optimisation;
- un endpoint `GET /health` versionne.

## Architecture cible

```text
voteclair/
├── api/
├── mobile/
├── docs/
├── infra/
│   └── docker/
│       ├── dev/
│       └── prod/
├── scripts/
├── .github/
│   └── workflows/
├── docker-compose.yml
└── docker-compose.prod.yml
```

## Variables d'environnement

Les fichiers versionnes de reference sont:

- `api/.env.example`
- `api/.env.production.example`
- `api/.env.staging.example`

Les fichiers reels a ne jamais versionner sont:

- `api/.env`
- `api/.env.production`
- `api/.env.staging`

Variables attendues pour les environnements de production et staging:

- `APP_NAME`
- `APP_ENV`
- `APP_KEY`
- `APP_DEBUG`
- `APP_URL`
- `API_VERSION`
- `DB_CONNECTION`
- `DB_HOST`
- `DB_PORT`
- `DB_DATABASE`
- `DB_USERNAME`
- `DB_PASSWORD`
- `REDIS_HOST`
- `REDIS_PORT`
- `REDIS_PASSWORD`
- `REDIS_CLIENT`
- `QUEUE_CONNECTION=redis`
- `CACHE_STORE=redis`
- `SESSION_DRIVER=database`
- configuration SMTP `MAIL_*`

## Docker production

Le Dockerfile de production est situe dans `infra/docker/prod/Dockerfile`.

Principes retenus:

- image independante du Dockerfile de dev;
- installation Composer sans dependances de developpement;
- build des assets Vite dans un stage Node dedie;
- runtime PHP-FPM + Nginx sans Node, sans cache Composer de dev et sans outils inutiles;
- logs Nginx vers `stdout` et `stderr`.

Le fichier `docker-compose.prod.yml` permet de tester localement cette image sans changer la stack de developpement.

Lancement local:

```bash
docker compose -f docker-compose.prod.yml up -d --build
```

Arret:

```bash
docker compose -f docker-compose.prod.yml down
```

L'API est alors disponible sur:

```text
http://localhost:8081
```

## PostgreSQL

La production cible PostgreSQL.

Pour les tests locaux de l'image de production, `docker-compose.prod.yml` demarre un service `postgres` dedie.

En hebergement Render, la cible est une base PostgreSQL managée injectee via les variables `DB_*`.

Avant tout deploiement, lancer les migrations:

```bash
php artisan migrate --force
```

## Redis

Redis est prevu pour:

- le cache Laravel;
- les files d'attente Laravel;
- les jobs de synchronisation CLAIR.

Variables minimales:

```env
QUEUE_CONNECTION=redis
CACHE_STORE=redis
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_CLIENT=phpredis
```

En production Render, Redis devra etre remplace par un service managé ou un endpoint dedie.

## Logs production

La production doit privilegier les logs de conteneur.

Reglages recommandes:

```env
LOG_CHANNEL=stderr
LOG_STACK=stderr
LOG_LEVEL=warning
VOTECLAIR_LOG_CHANNEL=stderr
```

Cette approche evite la dependance aux fichiers de logs internes au conteneur et facilite l'integration future avec Render.

## Storage

Le projet prepare explicitement l'usage de:

```bash
php artisan storage:link
```

Le script de deploiement cree ce lien symbolique si necessaire avant l'optimisation de l'application.

## Optimisation Laravel

Commandes prevues pour la production:

```bash
php artisan optimize
php artisan config:cache
php artisan route:cache
php artisan event:cache
php artisan view:cache
```

Pour repartir d'un etat propre:

```bash
php artisan optimize:clear
```

## Scripts

Scripts fournis a la racine du projet:

- `scripts/deploy.sh`
- `scripts/optimize.sh`

`scripts/deploy.sh` couvre:

- `composer install --no-dev`
- `php artisan migrate --force`
- `php artisan storage:link`
- `php artisan optimize`
- les caches `config`, `route`, `event` et `view`

`scripts/optimize.sh` couvre:

- purge des caches Laravel;
- reconstruction des caches de production.

## Healthcheck

VoteClair expose un endpoint public sans authentification:

```http
GET /health
```

Reponse attendue:

```json
{
  "status": "ok",
  "version": "1.0.0-beta"
}
```

Ce endpoint est destine aux integrations futures avec Render et UptimeRobot.

## Validation locale

Verifier la configuration Docker de production:

```bash
docker compose -f docker-compose.prod.yml config
```

Verifier le healthcheck:

```bash
curl http://localhost:8081/health
```

Verifier les routes Laravel:

```bash
cd api
php artisan route:list --path=health
```

## Render

Cette phase ne deploie rien encore.

Elle prepare uniquement le terrain pour la phase suivante:

- GitHub Actions;
- build et push automatiques;
- deploiement Render automatise;
- injection des secrets de production;
- verification de sante post-deploiement.