# Synchronisation incrémentale VoteClair

## Principe

Le pipeline `voteclair:sync` utilise des jobs Redis chaînés et conserve un état de progression dans la table `sync_states`.

Clés suivies:
- `last_groups_sync`
- `last_deputies_sync`
- `last_scrutins_sync`
- `last_votes_sync`

## Premier lancement

Quand aucune clé n'existe, la synchronisation est complète:

```bash
docker compose exec laravel php artisan voteclair:sync
```

## Lancements suivants

Les jobs lisent `last_*_sync` et ne récupèrent que les nouveautés (ou un fallback recent + filtrage local selon les capacités de l'API Clair).

## État et sécurité

Les clés `last_*_sync` ne sont mises à jour qu'en fin de job, après traitement réussi.

Si un job échoue:
- la clé n'est pas avancée
- la relance reprend correctement au prochain passage

## Monitoring

Afficher l'état courant:

```bash
docker compose exec laravel php artisan voteclair:sync-status
```

Lister les jobs échoués:

```bash
docker compose exec laravel php artisan queue:failed
```

Relancer:

```bash
docker compose exec laravel php artisan queue:retry all
```

## Worker et scheduler

Worker Redis:

```bash
docker compose exec laravel php artisan queue:work redis --queue=sync
```

Scheduler (sync quotidienne à 03:00):

```bash
docker compose exec laravel php artisan schedule:list
```

## Variables utiles

- `CLAIR_SYNC_BATCH_SIZE=100`
- `CLAIR_API_INCREMENTAL_RECENT_PAGES=5`
- `CLAIR_SYNC_VOTES_LIMIT=0`

## Rollback opérationnel

Pour forcer un import complet d'une entité, supprimer sa clé dans `sync_states`.

Exemple SQL:

```sql
DELETE FROM sync_states WHERE key = 'last_scrutins_sync';
```

Au run suivant, le job concerné repassera en mode complet.
