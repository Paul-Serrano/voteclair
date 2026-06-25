# Feature: Votes importants

## Objectif

Mettre en avant les scrutins les plus significatifs via un score d'importance calculable et extensible, puis exposer ces scrutins dans l'API et sur le dashboard mobile.

## Backend

### Donnees

- Colonne ajoutee: `scrutins.importance_score` (integer, default 0).
- Migration: `2026_06_25_000950_add_importance_score_to_scrutins_table.php`.

### Scoring extensible

Le scoring repose sur des regles composables:

- Contrat: `App\Services\Scrutins\Contracts\ImportanceRule`
- Service: `App\Services\Scrutins\ImportanceScoringService`
- Regles actuelles:
  - `SolennelImportanceRule`: +50 si "solennel" dans le titre ou le demandeur
  - `KeywordImportanceRule`: points par mots-cles strategiques
  - `HighParticipationImportanceRule`: +20 si exprimes (`pour + contre`) > 500
  - `TightResultImportanceRule`: +30 si ecart strictement inferieur a 20

Pour ajouter un nouveau critere, creer une nouvelle classe implementant `ImportanceRule` et l'enregistrer dans le constructeur de `ImportanceScoringService`.

### Recalcul global

Commande disponible:

- `php artisan voteclair:recalculate-importance`
- Option: `--chunk=200` pour ajuster la taille des lots.

La commande recalcule tous les scrutins, met a jour uniquement les scores modifies, puis invalide le cache des endpoints importants.

### Endpoint API

- Route: `GET /api/scrutins/important?limit=20`
- Limite: clamp entre 1 et 100
- Cache: 1 heure (cle `scrutins:important:{limit}`)
- Tri: `importance_score DESC`, puis `numero DESC`
- Filtre: seuls les scrutins avec `importance_score > 0`

Payload retourne:

- `id`
- `titre`
- `date_scrutin`
- `importance_score`
- `sort`

### Synchronisation

Lors de `SyncScrutinsJob`, les scrutins importes sont ensuite rescories via `ImportanceScoringService`. Les cles de cache des votes importants sont invalidees a la fin du job.

## Frontend mobile

Nouvelle feature Flutter: `features/important_votes`

- Entite: `ImportantVoteItem`
- Repository: `ImportantVotesRepository` + implementation Dio
- DTO: mapping de `/scrutins/important`
- Provider Riverpod:
  - `importantVotesProvider` (liste complete)
  - `importantVotesPreviewProvider` (preview dashboard, max 5)
- Widget: `ImportantVoteCard`

Integration dashboard:

- Section "Votes importants" sur la home
- Etats geres: loading, error, empty, success
- Navigation vers le detail scrutin au clic (`/scrutins/{id}`)

## Tests

- API: tests endpoint `/api/scrutins/important` (tri, limit, structure)
- Service/commande: tests de scoring et recalcul global
- Sync: schema de tests mis a jour avec `importance_score`
