# VoteClair

> Comprendre simplement comment votent vos députés.

## Présentation

VoteClair est un projet orienté transparence démocratique, avec une API Laravel et une application mobile (à venir), pour rendre les votes parlementaires lisibles par tous.

Le MVP cible l'Assemblée nationale. Le modèle de données a été conçu pour pouvoir intégrer ensuite le Sénat et le Parlement européen.

## Architecture actuelle du repository

```text
voteclair/
├── api/                    # Backend Laravel
│   ├── app/
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
│   ├── clair-api/          # Exemples et flux métier
│   └── copilot/            # Documentation technique (schéma DB)
├── mobile/                 # Placeholder (pas encore initialisé)
├── docker-compose.yml      # Stack locale Laravel + PostgreSQL + Redis + Adminer
└── readme.md
```

## Stack technique

- Backend: Laravel (PHP)
- Base de données: PostgreSQL
- Cache/queue: Redis
- Conteneurisation locale: Docker Compose
- Admin base de données: Adminer

## Services Docker disponibles

Le fichier [docker-compose.yml](docker-compose.yml) définit 4 services:

- `laravel`: API Laravel servie sur `http://localhost:8000`
- `postgres`: base PostgreSQL
- `redis`: cache et file d'attente
- `adminer`: interface DB sur `http://localhost:8080`

## Données et schéma

Le schéma de référence est documenté dans [docs/copilot/database-schema.md](docs/copilot/database-schema.md).

Les migrations VoteClair ont été ajoutées dans [api/database/migrations](api/database/migrations) avec:

- Types PostgreSQL: `vote_position`, `political_position`, `scrutin_result`
- Tables métier: `institutions`, `groups`, `circonscriptions`, `deputies`, `scrutins`, `votes`

## Démarrage rapide

### 1. Lancer la stack

```bash
docker compose up -d --build
```

### 2. Préparer l'environnement Laravel

```bash
cd api
cp .env.example .env
php artisan key:generate
```

### 3. Configurer la base dans `.env`

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

## Objectif produit (MVP)

- Import des députés, groupes, scrutins et votes
- API REST pour consultation citoyenne
- Recherche député / circonscription
- Fiches député et scrutin
- Application mobile consommatrice de l'API

## Documentation utile

- Vue d'ensemble du backend Laravel: [api/README.md](api/README.md)
- Schéma de base de données: [docs/copilot/database-schema.md](docs/copilot/database-schema.md)
- Exemple de parcours fonctionnel: [docs/clair-api/sample-flow.md](docs/clair-api/sample-flow.md)

## Statut

- Backend Laravel: initialisé
- Schéma DB + migrations métier: en place
- Mobile Flutter: non initialisé (dossier présent)

## Licence

Projet open source en cours de développement.