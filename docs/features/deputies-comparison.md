# Feature: Comparaison de deputes

## Objectif

Permettre de comparer deux deputes sur leurs votes communs, avec des indicateurs clairs:

- nombre de votes communs
- nombre d'accords
- nombre de desaccords
- abstentions communes
- taux d'accord
- liste des differences recentes

## Backend

### Endpoint

- `GET /api/deputies/compare?left_slug={slugA}&right_slug={slugB}`

Validation:

- `left_slug` requis, existe dans `deputies.slug`
- `right_slug` requis, existe dans `deputies.slug`
- `left_slug` et `right_slug` doivent etre differents

Reponse (resource):

```json
{
  "data": {
    "left": {
      "slug": "jean-dupont",
      "nom": "Dupont",
      "prenom": "Jean"
    },
    "right": {
      "slug": "marie-durand",
      "nom": "Durand",
      "prenom": "Marie"
    },
    "stats": {
      "common_votes": 120,
      "agreements": 86,
      "disagreements": 34,
      "same_abstentions": 7,
      "agreement_rate": 71.7
    },
    "recent_common_votes": [
      {
        "scrutin_id": "uuid",
        "numero": 1234,
        "titre": "Titre du scrutin",
        "date": "2026-06-20 12:34:56",
        "scrutin_sort": "ADOPTE",
        "importance_score": 120,
        "left_vote": "POUR",
        "right_vote": "POUR"
      }
    ],
    "recent_differences": [
      {
        "scrutin_id": "uuid",
        "numero": 1234,
        "titre": "Titre du scrutin",
        "date": "2026-06-20 12:34:56",
        "scrutin_sort": "ADOPTE",
        "importance_score": 120,
        "left_vote": "POUR",
        "right_vote": "CONTRE"
      }
    ]
  }
}
```

### Implementation

- Service: `App\Services\Deputies\DeputyComparisonService`
- Resource: `App\Http\Resources\DeputyComparisonResource`
- Controller method: `DeputyController::compare`
- Route: `Route::get('deputies/compare', ...)`

Details techniques:

- comparaison basee sur les scrutins communs (jointure SQL `votes` vs `votes`)
- calculs agrges en SQL (pas de chargement global en memoire)
- scan borne aux 100 votes communs les plus recents
- cache de 6h avec cle normalisee par ordre lexicographique des slugs

## Frontend mobile

### Nouveau module

- `mobile/lib/features/comparison/`
  - `domain/entities/deputy_comparison.dart`
  - `domain/repositories/comparison_repository.dart`
  - `data/dto/deputy_comparison_dto.dart`
  - `data/repositories/comparison_repository_impl.dart`
  - `presentation/providers/comparison_provider.dart`
  - `presentation/pages/comparison_page.dart`
  - `presentation/widgets/comparison_summary_card.dart`
  - `presentation/widgets/comparison_difference_tile.dart`

### UX

- Route ajoutee: `/compare`
- Acces rapide depuis le dashboard: "Comparer deux deputes"
- Selection de chaque depute via bottom sheet + barre de recherche
- Bouton "Comparer" active quand A et B sont valides et differents
- Affichage d'une carte resume des stats
- Filtre "Afficher": "Tous les scrutins communs" ou "Seulement les desaccords"
- Filtres/tri d'importance et numero appliques sur la liste affichée
- Navigation vers le detail scrutin (`/scrutins/{id}`)

## Tests

### Backend

Ajouts dans `ApiV1Test`:

- succes de la comparaison (structure, stats, differences)
- erreur 422 si slug invalide

### Frontend

- validation via `flutter analyze`
- regression validee via `flutter test`
