# Feature: Trouver mon depute

## Objectif

Permettre a un citoyen d'identifier rapidement son representant a partir de son code postal.

La fonctionnalite est construite pour rester compatible avec plusieurs institutions:

- Assemblee nationale
- Senat
- Parlement europeen

## Backend

### Schema

Nouvelle table: `postal_codes`

Colonnes:

- `id` BIGSERIAL PRIMARY KEY
- `postal_code` VARCHAR(10) NOT NULL
- `departement_code` VARCHAR(5) NOT NULL
- `institution_id` UUID NULL -> `institutions.id`
- `circonscription_id` UUID NOT NULL -> `circonscriptions.id`
- `created_at`
- `updated_at`

`circonscriptions` contient aussi `institution_id` pour permettre le routage futur vers plusieurs chambres sans refonte.

### Relations

- `PostalCode belongsTo Institution`
- `PostalCode belongsTo Circonscription`
- `Institution hasMany PostalCode`
- `Institution hasMany Circonscription`
- `Circonscription belongsTo Institution`

### Service

Classe: `App\Services\Deputies\FindMyDeputyService`

Methode:

- `findByPostalCode(string $postalCode, ?string $institutionId = null)`

Regles:

- recherche par code postal exact
- filtre optionnel par institution
- retourne les deputes rattaches a la circonscription
- inclut les 5 derniers votes de chaque depute
- resultat mis en cache 24h

### Endpoint

- `GET /api/find-my-deputy?postal_code=75001`
- `GET /api/find-my-deputy?postal_code=75001&institution_id=...`

Validation:

- `postal_code` requis, 5 chiffres
- `institution_id` nullable, doit exister dans `institutions`

### Reponse

```json
{
  "postal_code": "75001",
  "institution": {
    "id": "inst-an",
    "nom": "Assemblee nationale"
  },
  "circonscription": {
    "id": "cir-1",
    "nom": "Paris 1"
  },
  "deputies": [
    {
      "slug": "jean-dupont",
      "prenom": "Jean",
      "nom": "Dupont",
      "photo_url": null,
      "profession": "Ingenieur",
      "stats_presence": 91,
      "stats_loyaute": 84,
      "stats_participation": 123,
      "group": {
        "slug": "centre",
        "nom": "Centre",
        "couleur": "#00AAFF"
      },
      "latest_votes": []
    }
  ]
}
```

### Commande d'import

- `php artisan voteclair:import-postal-codes /chemin/vers/postal_codes.json`

La commande importe un fichier JSON de lignes postal code -> circonscription.

## Mobile

Nouveau module Flutter: `features/find_my_deputy/`

Structure:

- `data/`
- `domain/`
- `presentation/`

Ecrans et widgets:

- `FindMyDeputyPage`
- `PostalCodeSearchCard`
- `DeputyResultCard`

Fonctionnalites:

- saisie d'un code postal
- filtre optionnel `institution_id`
- affichage de l'institution et de la circonscription
- affichage du depute, de ses stats et de ses 5 derniers votes
- navigation vers la fiche depute et les scrutins

Route ajoutee:

- `/find-my-deputy`

Dashboard:

- carte de raccourci "Trouver mon depute"

## Tests

- API: recherche par code postal, filtre institutionnel, 404 si aucun resultat
- Flutter: saisie valide, validation du code postal, rendu du resultat

## Donnees d'import

Un exemple de fichier est fourni dans `docs/clair-api/postal_codes.sample.json`.