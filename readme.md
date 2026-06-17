# VoteClair

> Comprendre simplement comment votent vos députés.

## Présentation

VoteClair est une application mobile permettant à chaque citoyen de consulter et comprendre les votes des députés à l'Assemblée nationale française.

Aujourd'hui, les données parlementaires sont publiques mais restent difficiles d'accès et souvent complexes à interpréter. VoteClair a pour objectif de rendre ces informations accessibles au plus grand nombre grâce à une interface simple, claire et pédagogique.

Le projet se concentre dans un premier temps sur les votes des députés français à l'Assemblée nationale.

---

## Objectifs

- Rendre les votes des députés accessibles à tous.
- Simplifier la compréhension des scrutins parlementaires.
- Favoriser la transparence démocratique.
- Permettre aux citoyens de suivre l'activité de leurs représentants.

---

## Fonctionnalités du MVP

### Mon député

À partir du code postal de l'utilisateur :

- Identification du député de la circonscription.
- Présentation de sa fiche détaillée.
- Consultation de ses derniers votes.
- Taux de participation aux scrutins.

### Fiche député

Pour chaque député :

- Informations générales.
- Groupe parlementaire.
- Circonscription.
- Historique des votes.
- Statistiques de participation.
- Répartition des votes :
  - Pour
  - Contre
  - Abstention
  - Non-votant

### Fiche scrutin

Pour chaque vote :

- Titre du scrutin.
- Résumé simplifié du sujet voté.
- Date du vote.
- Résultat global.
- Répartition des votes.
- Liste des députés ayant participé.

### Recherche

- Recherche d'un député par nom.
- Recherche par circonscription.

### Sujets d'intérêt (version ultérieure)

L'utilisateur pourra sélectionner des thèmes :

- Écologie
- Santé
- Éducation
- Immigration
- Économie
- Pouvoir d'achat

L'application mettra alors en avant les votes liés à ces sujets.

---

## Principes du projet

VoteClair se veut :

- Neutre politiquement.
- Factuel.
- Transparent.
- Accessible.

L'application ne porte aucun jugement sur les votes des élus et se contente de présenter les données parlementaires de manière compréhensible.

---

## Architecture technique

### Backend

API REST développée avec Laravel.

#### Stack

- PHP 8+
- Laravel
- PostgreSQL
- Redis
- Docker

#### Responsabilités

- Synchronisation des données parlementaires.
- Exposition des données via API REST.
- Agrégation et enrichissement des données.
- Génération des statistiques.

#### Synchronisation des données

Les données de l'Assemblée nationale sont importées automatiquement grâce à :

- Laravel Jobs
- Laravel Queues
- Tâches planifiées

Cette architecture permet de :

- Importer de gros volumes de données.
- Mettre à jour régulièrement les votes.
- Garantir de bonnes performances.

#### Cache

Redis est utilisé pour :

- Mettre en cache les requêtes fréquentes.
- Réduire la charge sur PostgreSQL.
- Améliorer les temps de réponse.

---

### Mobile

Application développée avec Flutter.

#### Objectifs

- Application Android.
- Application iOS.
- Expérience utilisateur simple et rapide.
- Consommation exclusive de l'API REST Laravel.

---

## Architecture prévisionnelle

```text
voteclair/
├── api/
│   ├── app/
│   ├── database/
│   ├── routes/
│   └── docker/
│
├── mobile/
│   ├── lib/
│   ├── assets/
│   └── test/
│
└── docs/
```

## Modèle de données (prévisionnel)

```text
deputies
groups
constituencies
scrutins
votes
themes
```

### Exemple

Un scrutin :

```json
{
  "id": 1234,
  "title": "Projet de loi relatif à l'énergie",
  "date": "2026-06-17",
  "result": "adopté"
}
```

Un vote individuel :

```json
{
  "deputy": "Jean Dupont",
  "vote": "pour"
}
```

---

## Sources de données

Les données utilisées proviendront des jeux de données publics de l'Assemblée nationale française et des API open data associées.

---

## Roadmap

### MVP

- [ ] Import des députés
- [ ] Import des scrutins
- [ ] Import des votes individuels
- [ ] API REST publique
- [ ] Recherche de député
- [ ] Fiche député
- [ ] Fiche scrutin
- [ ] Application mobile Flutter

### V1

- [ ] Géolocalisation par code postal
- [ ] Fonction "Mon député"
- [ ] Catégorisation des votes par thème
- [ ] Statistiques avancées

### V2

- [ ] Notifications personnalisées
- [ ] Comparaison entre députés
- [ ] Historique des législatures
- [ ] Ouverture aux données du Sénat

---

## Licence

Projet open source en cours de développement.