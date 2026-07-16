# Phase Production 3.2 — Workers, Scheduler, Synchronisation et Observabilité

## Objectif

Rendre VoteClair totalement autonome.

À la fin de cette phase :

- les Workers exécutent automatiquement les Jobs ;
- le Scheduler Laravel orchestre les traitements ;
- les synchronisations Clair sont automatiques ;
- les statistiques sont recalculées automatiquement ;
- l'état du système est centralisé ;
- les événements techniques sont historisés ;
- le monitoring est prêt pour UptimeRobot et un futur Dashboard Admin.

---

# Architecture

                    GitHub
                       │
                       ▼
                 Render Web Service
                       │
                  API Laravel
                       │
        ┌──────────────┼──────────────┐
        │              │              │
        ▼              ▼              ▼
   Queue Worker    Scheduler      REST API
        │              │
        └──────┬───────┘
               ▼
        Redis (Upstash)
               │
               ▼
        PostgreSQL (Neon)

---

# Architecture de synchronisation

Scheduler
    │
    ▼
voteclair:sync
    │
    ▼
SyncManager
    │
    ├────────────┐
    ▼            ▼
ImportScrutinsJob
ImportVotesJob
UpdateDeputiesJob
UpdateGroupsJob
    │
    ▼
RecalculateStatisticsJob
    │
    ▼
UpdateSystemStatusJob
    │
    ▼
CreateSystemEventJob

Tous les traitements métier doivent être réalisés dans les Services.

Les Commands ne servent qu'à orchestrer.

---

# Étape 1 — Worker Render

Créer un Background Worker Render.

Commande :

php artisan queue:work \
    --queue=default \
    --tries=3 \
    --sleep=3 \
    --timeout=120

Le Worker partage exactement les mêmes variables d'environnement que le Web Service.

---

# Étape 2 — Cron Render

Créer un Cron Job Render.

Commande :

php artisan schedule:run

Fréquence :

* * * * *

---

# Étape 3 — Commande principale

Créer :

php artisan voteclair:sync

Cette commande :

- vérifie qu'aucune synchronisation n'est déjà en cours ;
- acquiert un verrou Redis ;
- lance le SyncManager ;
- libère le verrou.

Le verrou doit utiliser :

Cache::lock()

Aucun verrou SQL ne doit être créé.

---

# Étape 4 — Scheduler

Planifier :

Toutes les heures

- voteclair:sync

Toutes les nuits

- recalcul des statistiques

Toutes les semaines

- nettoyage des Jobs échoués

Toutes les semaines

- vérification de cohérence des données

---

# Étape 5 — Jobs

Tous les traitements lourds passent par Redis.

Exemples :

ImportScrutinsJob

ImportVotesJob

UpdateDeputiesJob

UpdateGroupsJob

RecalculateStatisticsJob

UpdateSystemStatusJob

CreateSystemEventJob

Tous les Jobs doivent :

- être idempotents ;
- être relançables ;
- être journalisés.

---

# Étape 6 — Table system_status

Créer une table :

system_status

Une seule ligne représente l'état actuel du système.

Colonnes :

id

api_version

clair_data_version

database_status

redis_status

queue_status

queue_pending_jobs

queue_failed_jobs

last_successful_sync_at

last_failed_sync_at

last_sync_status

last_sync_duration_ms

last_scrutins_imported

last_votes_imported

last_deputies_updated

last_groups_updated

created_at

updated_at

Cette table est utilisée par :

- GET /health
- Dashboard Admin
- Monitoring

Elle est mise à jour après chaque synchronisation.

---

# Étape 7 — Table system_events

Créer une table :

system_events

Historise tous les événements techniques.

Colonnes :

id

type

level

message

context (jsonb)

duration_ms

created_at

Types possibles :

sync.started

sync.finished

sync.failed

stats.recalculated

worker.started

worker.stopped

scheduler.started

scheduler.failed

database.error

redis.error

Le champ context doit être un JSONB PostgreSQL.

Il permet de stocker :

- nombre de votes importés
- nombre de scrutins
- exception
- URL Clair
- stacktrace
- etc.

---

# Étape 8 — Endpoint Health

Le endpoint

GET /health

ne réalise aucun calcul.

Il lit uniquement :

system_status

Retour attendu :

{
    "status":"ok",
    "database":"ok",
    "redis":"ok",
    "queue":"ok",
    "last_sync":"...",
    "sync_status":"success",
    "api_version":"1.0.0-beta"
}

---

# Étape 9 — Commande Diagnostic

Créer :

php artisan voteclair:status

Afficher :

API

PostgreSQL

Redis

Queue

Version API

Version Clair

Dernière synchronisation

Durée

Nombre de votes importés

Nombre de scrutins importés

Jobs en attente

Jobs échoués

---

# Étape 10 — Logging

Tous les Jobs doivent journaliser :

début

fin

durée

erreur

Tous les événements importants doivent également être enregistrés dans system_events.

---

# Étape 11 — Contraintes

Toute la logique métier reste dans les Services.

Les Commands ne font qu'orchestrer.

Le Scheduler ne contient aucune logique métier.

Les Jobs sont :

- idempotents
- relançables
- testables

Aucun verrou SQL.

Utiliser exclusivement :

Cache::lock()

---

# Documentation

Créer :

docs/operations/workers.md

Documenter :

- Worker Render
- Scheduler
- Cron
- Queue Redis
- SyncManager
- system_status
- system_events
- stratégie de synchronisation
- stratégie de monitoring

---

# Critères de validation

À la fin :

✓ Worker Render opérationnel

✓ Scheduler opérationnel

✓ Cron Render opérationnel

✓ Synchronisation automatique

✓ Statistiques automatiques

✓ Queue Redis opérationnelle

✓ Endpoint /health opérationnel

✓ Commande voteclair:status opérationnelle

✓ system_status mis à jour automatiquement

✓ system_events historise tous les événements techniques

✓ verrou Redis empêchant deux synchronisations simultanées