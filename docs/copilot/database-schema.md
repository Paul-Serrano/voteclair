# Database Schema - VoteClair

## Objectif

Ce document décrit le modèle de données du projet VoteClair.

L'objectif est de permettre la synchronisation des données parlementaires provenant de plusieurs institutions :

- Assemblée nationale
- Sénat
- Parlement européen

Le MVP se concentre uniquement sur l'Assemblée nationale, mais le schéma doit être compatible avec les futures extensions.

---

# Conventions

## Clés primaires

Toutes les entités synchronisées depuis une source externe utilisent l'UUID fourni par la source comme clé primaire.

```text
id UUID PRIMARY KEY
```

## Synchronisation

Toutes les tables synchronisées doivent contenir :

```text
last_synced_at TIMESTAMP NULL
created_at TIMESTAMP
updated_at TIMESTAMP
```

---

# PostgreSQL Enums

## vote_position

```sql
CREATE TYPE vote_position AS ENUM (
    'POUR',
    'CONTRE',
    'ABSTENTION',
    'NON_VOTANT'
);
```

Utilisé par la table `votes`.

---

## political_position

```sql
CREATE TYPE political_position AS ENUM (
    'EXTREME_GAUCHE',
    'GAUCHE',
    'CENTRE_GAUCHE',
    'CENTRE',
    'CENTRE_DROIT',
    'DROITE',
    'EXTREME_DROITE'
);
```

Utilisé par la table `groups`.

---

## scrutin_result

```sql
CREATE TYPE scrutin_result AS ENUM (
    'ADOPTE',
    'REJETE'
);
```

Utilisé par la table `scrutins`.

---

# Laravel Migration Rules

## PostgreSQL Enums

Utiliser de vrais ENUM PostgreSQL.

Les migrations Laravel devront créer les ENUM PostgreSQL via :

```php
DB::statement(...)
```

avant la création des tables concernées.

Ne pas utiliser de VARCHAR pour représenter des valeurs métier finies.

---

# institutions

Référentiel des institutions parlementaires.

## Colonnes

| Champ | Type |
|---------|---------|
| id | UUID PK |
| slug | VARCHAR(50) UNIQUE |
| nom | VARCHAR(255) |
| pays | VARCHAR(100) |
| actif | BOOLEAN |
| last_synced_at | TIMESTAMP NULL |
| created_at | TIMESTAMP |
| updated_at | TIMESTAMP |

## Exemples

```text
assemblee-nationale
senat
parlement-europeen
```

---

# groups

Groupes parlementaires.

## Colonnes

| Champ | Type |
|---------|---------|
| id | UUID PK |
| institution_id | UUID FK -> institutions.id |
| source_id | VARCHAR(50) NULL |
| slug | VARCHAR(50) UNIQUE |
| nom | VARCHAR(100) |
| nom_complet | VARCHAR(255) |
| couleur | VARCHAR(7) |
| logo_url | TEXT NULL |
| position | political_position NULL |
| ordre | INTEGER NULL |
| actif | BOOLEAN |

## Statistiques

| Champ | Type |
|---------|---------|
| stats_membres_actifs | INTEGER NULL |
| stats_presence_moyenne | SMALLINT NULL |
| stats_presence_solennel_moyenne | SMALLINT NULL |
| stats_loyaute_moyenne | SMALLINT NULL |
| stats_cohesion | SMALLINT NULL |
| stats_participation | INTEGER NULL |
| stats_votes_pour | INTEGER NULL |
| stats_votes_contre | INTEGER NULL |
| stats_votes_abstention | INTEGER NULL |
| stats_votes_absent | INTEGER NULL |
| stats_calculated_at | TIMESTAMP NULL |

## Synchronisation

| Champ | Type |
|---------|---------|
| last_synced_at | TIMESTAMP NULL |
| created_at | TIMESTAMP |
| updated_at | TIMESTAMP |

---

# circonscriptions

Référentiel des circonscriptions électorales.

## Colonnes

| Champ | Type |
|---------|---------|
| id | UUID PK |
| departement | VARCHAR(5) |
| departement_name | VARCHAR(255) NULL |
| numero | INTEGER |
| nom | VARCHAR(255) |
| last_synced_at | TIMESTAMP NULL |
| created_at | TIMESTAMP |
| updated_at | TIMESTAMP |

---

# deputies

Députés, sénateurs ou eurodéputés.

## Colonnes

| Champ | Type |
|---------|---------|
| id | UUID PK |
| institution_id | UUID FK -> institutions.id |
| groupe_id | UUID FK -> groups.id |
| circonscription_id | UUID FK -> circonscriptions.id NULL |

## Identité

| Champ | Type |
|---------|---------|
| source_id | VARCHAR(50) UNIQUE |
| slug | VARCHAR(255) UNIQUE |
| nom | VARCHAR(255) |
| prenom | VARCHAR(255) |

## Informations générales

| Champ | Type |
|---------|---------|
| profession | VARCHAR(255) NULL |
| email | VARCHAR(255) NULL |
| twitter | VARCHAR(255) NULL |
| photo_url | TEXT NULL |
| actif | BOOLEAN |

## Statistiques

| Champ | Type |
|---------|---------|
| stats_presence | SMALLINT NULL |
| stats_presence_solennel | SMALLINT NULL |
| stats_loyaute | SMALLINT NULL |
| stats_participation | INTEGER NULL |
| stats_interventions | INTEGER NULL |
| stats_amendements | INTEGER NULL |
| stats_amendements_adoptes | INTEGER NULL |
| stats_questions | INTEGER NULL |

## Contenu IA

| Champ | Type |
|---------|---------|
| resume_ia | TEXT NULL |
| parcours_ia | TEXT NULL |
| positions_cles_ia | TEXT NULL |
| faits_notables_ia | TEXT NULL |

## Synchronisation

| Champ | Type |
|---------|---------|
| last_synced_at | TIMESTAMP NULL |
| created_at | TIMESTAMP |
| updated_at | TIMESTAMP |

---

# scrutins

Vote officiel d'une institution.

## Colonnes

| Champ | Type |
|---------|---------|
| id | UUID PK |
| institution_id | UUID FK -> institutions.id |

## Métadonnées

| Champ | Type |
|---------|---------|
| numero | INTEGER UNIQUE |
| date | TIMESTAMP |
| titre | TEXT |
| sort | scrutin_result |
| demandeur_texte | TEXT NULL |
| source_url | TEXT NULL |

## Dossier législatif

| Champ | Type |
|---------|---------|
| dossier_titre | TEXT NULL |
| dossier_url | TEXT NULL |

## Contenu IA

| Champ | Type |
|---------|---------|
| resume_ia | TEXT NULL |

## Synchronisation

| Champ | Type |
|---------|---------|
| last_synced_at | TIMESTAMP NULL |
| created_at | TIMESTAMP |
| updated_at | TIMESTAMP |

---

# votes

Vote individuel d'un parlementaire lors d'un scrutin.

Une ligne = un parlementaire + un scrutin.

## Colonnes

| Champ | Type |
|---------|---------|
| id | BIGSERIAL PK |
| scrutin_id | UUID FK -> scrutins.id |
| deputy_id | UUID FK -> deputies.id |
| position | vote_position |
| delegated | BOOLEAN DEFAULT FALSE |
| created_at | TIMESTAMP |
| updated_at | TIMESTAMP |

## Contraintes

```sql
UNIQUE(scrutin_id, deputy_id)
```

---

# Relations

```text
institutions
│
├── groups
│   └── deputies
│
├── circonscriptions
│   └── deputies
│
├── deputies
│   └── votes
│
└── scrutins
    └── votes
```

---

# Index recommandés

## institutions

```text
slug
```

---

## groups

```text
slug
institution_id
position
```

---

## circonscriptions

```text
departement
numero
```

---

## deputies

```text
slug
nom
institution_id
groupe_id
circonscription_id
source_id
```

---

## scrutins

```text
numero
date
institution_id
sort
```

---

## votes

```text
scrutin_id
deputy_id
position
(scrutin_id, deputy_id) UNIQUE
```

---

# MVP Scope

Les entités suivantes sont volontairement exclues du MVP :

```text
amendements
commissions
organes
mandats
questions écrites
questions orales
```

Elles pourront être ajoutées ultérieurement sans remettre en cause le modèle actuel.