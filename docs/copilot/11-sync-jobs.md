# Sprint 11 - Synchronisation automatique des données

## Objectif

Automatiser la récupération des données parlementaires.

L'application ne doit plus dépendre d'un import manuel.

Les données doivent être synchronisées automatiquement depuis l'API Clair.

---

# Architecture cible

```text
API Clair
    ↓
SyncCommand
    ↓
Jobs Redis
    ↓
Database PostgreSQL
```

---

# Infrastructure

## Redis

Ajouter Redis au docker-compose.

Services :

```yaml
redis:
  image: redis:7-alpine
```

---

## Laravel

Configurer :

```env
QUEUE_CONNECTION=redis
CACHE_STORE=redis
```

---

## Vérification

La commande suivante doit fonctionner :

```bash
php artisan queue:work
```

---

# Commande principale

Créer :

```bash
php artisan make:command SyncParliamentDataCommand
```

Nom :

```bash
voteclair:sync
```

---

# Responsabilité

La commande ne doit pas faire de logique métier.

Elle doit uniquement dispatcher les jobs.

---

# Jobs

Créer :

```bash
php artisan make:job SyncGroupsJob
php artisan make:job SyncDeputiesJob
php artisan make:job SyncScrutinsJob
php artisan make:job SyncVotesJob
```

---

# Ordre d'exécution

Respecter :

```text
1. Groups
2. Deputies
3. Scrutins
4. Votes
```

---

# Chaining

Utiliser :

```php
Bus::chain()
```

---

# Exemple attendu

```php
Bus::chain([
    new SyncGroupsJob(),
    new SyncDeputiesJob(),
    new SyncScrutinsJob(),
    new SyncVotesJob(),
])->dispatch();
```

---

# Services

Créer :

```text
app/Services/Clair/
```

---

# Services attendus

```php
ClairApiClient
```

Responsable :

* appels HTTP
* retry
* timeout
* gestion erreurs

---

# Méthodes minimales

```php
getGroups()
getDeputies()
getScrutins()
getVotes()
```

---

# HTTP Client

Utiliser :

```php
Http::retry()
```

---

# Timeout

```php
30 secondes
```

---

# Logging

Créer un canal :

```php
voteclair
```

---

# Journaliser

Début sync :

```text
Sync started
```

---

Fin sync :

```text
Sync completed
```

---

Erreur :

```text
Sync failed
```

---

# Idempotence

Tous les jobs doivent pouvoir être relancés.

Utiliser :

```php
updateOrCreate()
```

ou

```php
upsert()
```

---

# Transactions

Pour chaque lot :

```php
DB::transaction()
```

---

# Batch Processing

Ne jamais charger tout en mémoire.

Traiter par lots.

Exemple :

```php
100
```

enregistrements à la fois.

---

# Monitoring

Ajouter :

```bash
php artisan queue:failed
```

---

Créer une documentation :

```text
docs/operations/sync.md
```

Expliquant :

* démarrage
* worker
* relance
* monitoring

---

# Scheduler

Créer une tâche planifiée.

Fréquence :

```php
dailyAt('03:00')
```

---

# Kernel

Ajouter :

```php
Schedule::command('voteclair:sync')
```

---

# Critère de validation

Les éléments suivants doivent fonctionner :

* Redis opérationnel
* Queue Redis opérationnelle
* voteclair:sync opérationnelle
* Jobs chaînés
* Scheduler configuré
* Logs présents
* Relance sans doublons
* Synchronisation complète automatisée

```
```
