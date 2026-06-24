# Synchronisation automatique VoteClair

## Vue d'ensemble

La synchronisation automatisée récupère les données parlementaires depuis l'API Clair et les charge dans PostgreSQL via une chaîne de jobs Laravel exécutés sur Redis.

Architecture:
- API Clair
- commande `voteclair:sync`
- jobs Redis chaînés avec `Bus::chain()`
- PostgreSQL

Ordre d'exécution:
1. `SyncGroupsJob`
2. `SyncDeputiesJob`
3. `SyncScrutinsJob`
4. `SyncVotesJob`

## Démarrage

Construire et démarrer les conteneurs:

```bash
docker compose up -d --build
```

Vérifier que Redis répond:

```bash
docker compose exec redis redis-cli ping
```

Réponse attendue:

```text
PONG
```

## Lancer une synchronisation

Dispatcher la chaîne de jobs:

```bash
docker compose exec laravel php artisan voteclair:sync
```

Le job ne fait aucune logique métier dans la commande. Toute la logique est exécutée dans les jobs chaînés.

## Démarrer un worker

Lancer un worker Redis Laravel:

```bash
docker compose exec laravel php artisan queue:work redis --queue=sync
```

## Scheduler

La synchronisation quotidienne est planifiée à `03:00`.

Pour exécuter le scheduler en continu:

```bash
docker compose exec laravel php artisan schedule:work
```

Pour vérifier une exécution ponctuelle:

```bash
docker compose exec laravel php artisan schedule:run
```

## Monitoring

Lister les jobs échoués:

```bash
docker compose exec laravel php artisan queue:failed
```

Relancer les jobs échoués:

```bash
docker compose exec laravel php artisan queue:retry all
```

Purger les jobs échoués:

```bash
docker compose exec laravel php artisan queue:flush
```

## Logs

Canal dédié: `voteclair`

En développement, si `VOTECLAIR_LOG_CHANNEL=stderr`, les logs sont visibles dans les logs du conteneur Laravel.

Sinon, ils sont écrits dans:

```text
api/storage/logs/voteclair.log
```

Messages attendus:
- `Sync started`
- `Sync completed`
- `Sync failed`

## Relance et idempotence

Les jobs sont relançables sans doublons.

Mécanismes utilisés:
- `upsert()` sur les tables métier
- transactions par lot
- contraintes uniques en base

## Réglages utiles

Variables d'environnement principales:
- `QUEUE_CONNECTION=redis`
- `CACHE_STORE=redis`
- `REDIS_HOST=redis`
- `CLAIR_SYNC_BATCH_SIZE=100`
- `CLAIR_SYNC_VOTES_LIMIT=0`
- `CLAIR_SYNC_CHAMBER=assemblee`

## Dépannage

Si `php artisan queue:work` échoue avec une erreur Redis:
- reconstruire le conteneur Laravel pour installer l'extension PHP Redis
- vérifier `REDIS_HOST=redis`
- vérifier que le conteneur Redis est démarré

Commandes utiles:

```bash
docker compose ps
docker compose logs laravel --tail=200
docker compose logs redis --tail=200
```
