# Sprint 12 - Synchronisation incrémentale

## Objectif

Optimiser la synchronisation des données parlementaires.

Aujourd'hui, la commande :

```bash
php artisan voteclair:sync
```

réimporte l'ensemble des données à chaque exécution.

L'objectif est désormais de :

* synchroniser uniquement les nouveautés
* réduire le temps d'exécution
* diminuer les appels à l'API Clair
* préparer les futures notifications

---

# Vision cible

Aujourd'hui :

```text
Sync
 ├── Tous les groupes
 ├── Tous les députés
 ├── Tous les scrutins
 └── Tous les votes
```

Demain :

```text
Sync
 ├── Nouveaux groupes
 ├── Nouveaux députés
 ├── Nouveaux scrutins
 └── Nouveaux votes
```

---

# Nouvelle table

Créer :

```sql
sync_states
```

---

# Structure

```sql
id BIGSERIAL PRIMARY KEY

key VARCHAR(100) UNIQUE NOT NULL

value TEXT NULL

created_at TIMESTAMP
updated_at TIMESTAMP
```

---

# Exemples

```text
last_groups_sync
last_deputies_sync
last_scrutins_sync
last_votes_sync
```

---

# Modèle Laravel

Créer :

```php
App\Models\SyncState
```

---

# Service

Créer :

```php
App\Services\Sync\SyncStateService
```

---

# Méthodes attendues

```php
get(string $key): ?string

set(string $key, string $value): void

has(string $key): bool
```

---

# Stratégie

## Premier lancement

Si aucune valeur n'existe :

```text
Import complet
```

---

## Lancements suivants

Importer uniquement les données plus récentes que :

```text
last_xxx_sync
```

---

# ClairApiClient

Compléter :

```php
getUpdatedGroups(DateTimeInterface $since)

getUpdatedDeputies(DateTimeInterface $since)

getUpdatedScrutins(DateTimeInterface $since)

getUpdatedVotes(DateTimeInterface $since)
```

---

# Si l'API Clair ne supporte pas les filtres

Prévoir un fallback :

```text
Import des données récentes uniquement
```

puis filtrage côté Laravel.

---

# Détection des nouveautés

Pour chaque entité :

Comparer :

```text
updated_at
source_updated_at
date_scrutin
```

selon les données disponibles.

---

# Jobs

Modifier :

```php
SyncGroupsJob
SyncDeputiesJob
SyncScrutinsJob
SyncVotesJob
```

---

# Workflow attendu

Exemple :

```text
Lire last_scrutins_sync

↓

Récupérer uniquement les nouveaux scrutins

↓

Upsert

↓

Mettre à jour last_scrutins_sync
```

---

# Gestion des erreurs

Ne jamais mettre à jour :

```text
last_*_sync
```

si le job échoue.

---

# Transactions

Utiliser :

```php
DB::transaction()
```

sur chaque lot traité.

---

# Batch Processing

Conserver :

```text
100
```

éléments par lot.

---

# Logging

Ajouter :

```text
Scrutins imported: 0
Scrutins imported: 14
Votes imported: 258
```

---

# Monitoring

Créer :

```bash
php artisan voteclair:sync-status
```

---

# Commande

Créer :

```php
SyncStatusCommand
```

---

# Exemple de sortie

```text
Groups sync :
2026-06-24 03:00:00

Deputies sync :
2026-06-24 03:00:00

Scrutins sync :
2026-06-24 03:00:00

Votes sync :
2026-06-24 03:00:00
```

---

# Dashboard Admin futur

Préparer une structure compatible avec un futur écran :

```text
Administration
 └── Synchronisation
```

---

# Documentation

Créer :

```text
docs/operations/incremental-sync.md
```

---

# Contenu

Documenter :

* fonctionnement
* premier lancement
* relance
* rollback
* monitoring

---

# Critère de validation

Après un premier import complet :

```bash
php artisan voteclair:sync
```

ne doit importer que les nouvelles données.

Les jobs doivent :

* rester idempotents
* éviter les doublons
* réduire fortement le temps d'exécution

La commande :

```bash
php artisan voteclair:sync-status
```

doit afficher l'état actuel des synchronisations.
