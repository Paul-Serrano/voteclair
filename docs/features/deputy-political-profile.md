# Feature: Profil politique d'un depute

## Objectif

Enrichir la fiche depute avec des indicateurs politiques concrets:

- vote le plus frequent
- proximite avec son groupe
- top 5 sujets votes
- taux de presence
- taux de loyaute

## Backend

### Calcul

Service: `App\Services\Deputies\DeputyPoliticalProfileService`

Le service calcule et met en cache (6h):

- `most_frequent_vote`
- `most_frequent_vote_count`
- `group_proximity_rate`
- `group_proximity_votes_count`
- `top_topics` (top 5 sur `COALESCE(scrutins.dossier_titre, scrutins.titre)`)
- `presence_rate`
- `loyalty_rate`

Details:

- proximite groupe calculee sur les scrutins communs avec les autres membres du groupe
- en cas d'egalite de majorite de groupe sur un scrutin, ce scrutin est ignore
- en cas d'egalite sur le vote le plus frequent, priorite: POUR > CONTRE > ABSTENTION > NON_VOTANT

### Exposition API

`GET /api/deputies/{slug}` inclut maintenant:

```json
{
  "data": {
    "political_profile": {
      "most_frequent_vote": "POUR",
      "most_frequent_vote_count": 123,
      "group_proximity_rate": 72.4,
      "group_proximity_votes_count": 89,
      "top_topics": [
        {"label": "Projet de loi Climat", "count": 14}
      ],
      "presence_rate": 91,
      "loyalty_rate": 84
    }
  }
}
```

## Mobile

La fiche depute affiche une section "Profil politique" avec:

- vote frequent
- proximite groupe
- presence / loyaute
- top sujets votes

Fichiers:

- `mobile/lib/features/deputies/domain/entities/deputy.dart`
- `mobile/lib/features/deputies/data/dto/deputy_dto.dart`
- `mobile/lib/features/deputies/presentation/pages/deputy_details_page.dart`

## Tests

- `ApiV1Test::test_deputy_show_uses_slug_route_binding` valide la presence et la structure de `political_profile`.
- `flutter analyze` et `flutter test` valident l'integration mobile.
