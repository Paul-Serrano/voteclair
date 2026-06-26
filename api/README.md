# VoteClair API

API Laravel du projet VoteClair.

Ce backend alimente l'application mobile et expose les donnees parlementaires sous forme d'API REST. Il gere aussi les imports CLAIR, les synchronisations incrémentales, les calculs derives et plusieurs endpoints metier pour les deputes, groupes, scrutins et votes.

## Ce Que Couvre Le Backend

- import des deputes, groupes, scrutins et votes;
- synchronisation des donnees deja importees;
- pages de detail pour les deputes, groupes et scrutins;
- recherche et endpoints de consultation;
- calculs derives comme les scores ou les indicateurs de scrutins importants;
- jobs asynchrones pour les traitements lourds.

## Structure Principale

```text
app/
├── Console/
├── Http/
├── Jobs/
├── Models/
├── Providers/
└── Services/

database/
├── migrations/
├── factories/
└── seeders/

routes/
├── api.php
├── web.php
└── console.php

tests/
├── Feature/
└── Unit/
```

## Mise En Route Locale

### 1. Installer les dependances

```bash
cd api
composer install
```

### 2. Preparer la configuration

```bash
cp .env.example .env
php artisan key:generate
```

### 3. Configurer la base

Le backend attend une base PostgreSQL accessible depuis le service Docker `postgres`.

```env
DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=voteclair
DB_USERNAME=voteclair
DB_PASSWORD=voteclair
```

### 4. Lancer les migrations

```bash
php artisan migrate
```

## Commandes Utiles

- `php artisan test` pour verifier les tests;
- `php artisan clair:import:scrutins` pour relancer l'import des scrutins;
- `php artisan voteclair:sync-status` pour consulter l'etat des synchronisations;
- `php artisan voteclair:recalculate-importance` pour recalculer les scrutins importants.

## Documentation Utile

- README racine du projet: [../readme.md](../readme.md)
- Schema de base de donnees: [../docs/copilot/database-schema.md](../docs/copilot/database-schema.md)
- Flux d'import CLAIR: [../docs/clair-api/sample-flow.md](../docs/clair-api/sample-flow.md)

## Notes D'Exploitation

- Les imports CLAIR sont rate-limites et utilisent du backoff.
- Les gros imports doivent etre lances dans le conteneur Laravel pour profiter du reseau Docker.
- En cas de grosse volumetrie, reduire la taille des pages et augmenter la memoire PHP peut eviter les erreurs de flux.

## License

Ce projet suit la licence du repository principal.
