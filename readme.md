# VoteClair

> Comprendre simplement comment votent vos deputes.

VoteClair est un projet de transparence democratique qui transforme les donnees parlementaires en informations lisibles, recherchables et reutilisables. Le repository contient aujourd'hui le backend Laravel, la stack locale Docker et la documentation de reference du projet.

Le MVP cible d'abord l'Assemblee nationale. Le modele de donnees et l'architecture ont ete prepares pour pouvoir etendre ensuite le projet a d'autres chambres, comme le Senat ou le Parlement europeen.

## Ce Que Fait VoteClair

Le projet vise a rendre les votes parlementaires plus simples a comprendre pour un citoyen, un journaliste ou un observateur public. Les fonctionnalites principales sont:

- import des deputes, groupes, scrutins et votes depuis la source de donnees CLAIR;
- consultation des fiches deputes avec parcours politique et activite de vote;
- consultation des fiches scrutins avec detail du resultat et des positions de vote;
- recherche par deputes, groupes, circonscriptions et scrutins;
- calcul et affichage de signaux utiles pour mettre en avant les scrutins importants;
- base technique preparee pour alimenter plus tard une application mobile.

## Architecture Du Repository

```text
voteclair/
├── api/                    # Backend Laravel
│   ├── app/
│   ├── bootstrap/
│   ├── config/
│   ├── database/
│   │   ├── migrations/
│   │   ├── factories/
│   │   └── seeders/
│   ├── routes/
│   ├── resources/
│   └── tests/
├── docker/
│   └── php/
│       └── Dockerfile
├── docs/
│   ├── clair-api/          # Exemples de donnees, flux et imports
│   ├── copilot/            # Schema de base et notes techniques
│   ├── features/           # Specifications fonctionnelles
│   └── operations/         # Notes d'exploitation et de synchronisation
├── mobile/                 # Application Flutter a venir / en cours de montage
├── docker-compose.yml      # Stack locale Laravel + PostgreSQL + Redis + Adminer
└── readme.md
```

## Stack Technique

- Backend: Laravel / PHP
- Base de donnees: PostgreSQL
- Cache et files d'attente: Redis
- Execution locale: Docker Compose
- Interface DB: Adminer

## Services Docker

Le fichier [docker-compose.yml](docker-compose.yml) definit quatre services:

- `laravel`: API Laravel exposee sur `http://localhost:8000`
- `postgres`: base PostgreSQL du projet
- `redis`: cache et queue
- `adminer`: interface de consultation des donnees sur `http://localhost:8080`

## Donnees Et Schema

Le schema de reference est documente dans [docs/copilot/database-schema.md](docs/copilot/database-schema.md).

Les migrations principales du projet se trouvent dans [api/database/migrations](api/database/migrations) et definissent notamment:

- les types PostgreSQL `vote_position`, `political_position` et `scrutin_result`;
- les tables metier `institutions`, `groups`, `circonscriptions`, `deputies`, `scrutins` et `votes`;
- les relations permettant de lier les deputes aux groupes, circonscriptions et scrutins;
- les champs utilises pour la recherche, la synchronisation et les pages de detail.

## Fonctionnalites Backend

Le backend Laravel couvre les briques suivantes:

- import initial et synchronisation des donnees CLAIR;
- commandes artisan pour relancer des imports ou recalculer certains champs derives;
- jobs de synchronisation executes en arriere-plan;
- API REST pour les fiches et les recherches;
- tests de regression sur les imports, la synchronisation et les cas metier importants.

Pour les details d'implementation Laravel, voir [api/README.md](api/README.md).

## Démarrage Rapide

### 1. Demarrer la stack

```bash
docker compose up -d --build
```

### 2. Preparer Laravel

```bash
cd api
cp .env.example .env
php artisan key:generate
```

### 3. Configurer la base

Dans le fichier d'environnement du backend, verifier les valeurs suivantes:

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

### 5. Acceder a l'application

- API Laravel: `http://localhost:8000`
- Adminer: `http://localhost:8080`

## Commandes Utiles

Les commandes exactes peuvent evoluer, mais les flux principaux sont les suivants:

- import des donnees CLAIR pour les deputes, groupes, scrutins et votes;
- synchronisation incrementale des donnees deja importees;
- recalcul de certaines informations derivees, comme l'importance d'un scrutin;
- execution de la suite de tests Laravel.

Si tu veux voir les flux de donnees et les exemples d'import, consulte [docs/clair-api/sample-flow.md](docs/clair-api/sample-flow.md).

## Documentation Utile

- Vue d'ensemble du backend Laravel: [api/README.md](api/README.md)
- Schema de base de donnees: [docs/copilot/database-schema.md](docs/copilot/database-schema.md)
- Parcours fonctionnel exemple: [docs/clair-api/sample-flow.md](docs/clair-api/sample-flow.md)
- Documentation API et schemas lies: [docs/clair-api](docs/clair-api)
- Specifications fonctionnelles: [docs/features](docs/features)

## Etat Du Projet

- Backend Laravel: en place
- Schema DB et migrations metier: en place
- Synchronisation CLAIR: active sur les principaux objets metier
- Mobile Flutter: dossier present, mais application encore en construction

## Notes D'Exploitation

- L'API CLAIR peut etre rate-limitee; les imports recents utilisent donc du backoff et des traitements par pages.
- Les imports lourds doivent etre lances dans le conteneur Laravel pour profiter du reseau Docker et des dependances correctes.
- En cas d'import volumineux, il peut etre utile de reduire la taille de page et d'augmenter la memoire PHP.

## Licence

Projet open source en cours de developpement.
