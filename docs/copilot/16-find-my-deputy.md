# Sprint 16 - Trouver mon député

## Objectif

Permettre à un citoyen d'identifier rapidement son représentant à partir de son code postal.

Cette fonctionnalité doit devenir l'un des principaux points d'entrée de VoteClair.

Le design doit être compatible avec l'évolution future vers :

* Assemblée nationale
* Sénat
* Parlement européen

---

# Vision Produit

L'utilisateur saisit :

13008

Puis VoteClair affiche :

Votre député

* Nom
* Photo
* Groupe politique
* Profession

Statistiques :

* Présence
* Loyauté
* Participation

Derniers votes :

* 5 derniers scrutins

---

# Architecture Multi-Institutions

VoteClair supporte déjà :

* institutions
* groups
* deputies
* scrutins

Toutes les nouvelles tables doivent être compatibles avec ce modèle.

---

# Table postal_codes

Créer :

postal_codes

Structure :

```sql
id BIGSERIAL PRIMARY KEY

postal_code VARCHAR(10) NOT NULL

departement_code VARCHAR(5) NOT NULL

institution_id BIGINT NULL

circonscription_id BIGINT NOT NULL

created_at TIMESTAMP NULL
updated_at TIMESTAMP NULL
```

---

# Relations

postal_codes

* belongsTo Institution
* belongsTo Circonscription

---

# Circonscriptions

Vérifier que la table circonscriptions contient :

```sql
institution_id BIGINT NOT NULL
```

Structure minimale :

```sql
id BIGSERIAL PRIMARY KEY

institution_id BIGINT NOT NULL

source_id VARCHAR(255)

nom VARCHAR(255)

departement_code VARCHAR(5)

departement_name VARCHAR(255)

numero INTEGER

created_at TIMESTAMP NULL
updated_at TIMESTAMP NULL
```

---

# Pourquoi institution_id ?

Aujourd'hui :

13008
↓
Circonscription Assemblée Nationale
↓
Député

Demain :

13008
↓
Assemblée Nationale
↓
Député

13008
↓
Sénat
↓
Sénateur

13008
↓
Parlement Européen
↓
Eurodéputé

Sans migration supplémentaire.

---

# Modèle Laravel

Créer :

PostalCode

Relations :

* institution()
* circonscription()

---

# Dataset

Importer un dataset public :

* code postal
* département
* circonscription

Prévoir un importateur dédié.

---

# Commande

Créer :

php artisan voteclair:import-postal-codes

---

# Service métier

Créer :

App\Services\Deputies\FindMyDeputyService

Méthode :

findByPostalCode(
string $postalCode,
?int $institutionId = null
)

---

# Endpoint principal

Créer :

GET /api/find-my-deputy

---

# Paramètres

Requis :

postal_code

Optionnel :

institution_id

---

# Exemple

GET /api/find-my-deputy?postal_code=13008

GET /api/find-my-deputy?postal_code=13008&institution_id=1

---

# Validation

postal_code :

* 5 chiffres

institution_id :

* nullable
* existe dans institutions

---

# Workflow

Code postal
↓
PostalCode
↓
Circonscription
↓
Députés
↓
Derniers votes

---

# Réponse

```json
{
  "postal_code": "13008",

  "institution": {
    "id": 1,
    "nom": "Assemblée nationale"
  },

  "circonscription": {
    "id": 12,
    "nom": "13 - Circonscription 8"
  },

  "deputies": [
    {
      "slug": "example",

      "prenom": "Jean",

      "nom": "Dupont",

      "photo_url": "...",

      "profession": "...",

      "stats_presence": 92,

      "stats_loyaute": 88,

      "groupe": {
        "nom": "Renaissance"
      },

      "latest_votes": []
    }
  ]
}
```

---

# Resource

Créer :

FindMyDeputyResource

---

# Cache

Mettre en cache les recherches :

24 heures

Clé :

postal_code + institution_id

---

# Flutter

Créer :

features/find_my_deputy/

Structure :

data/
domain/
presentation/

presentation/pages/
find_my_deputy_page.dart

presentation/widgets/
postal_code_search_card.dart

presentation/widgets/
deputy_result_card.dart

---

# Repository

Créer :

FindMyDeputyRepository

---

# Route

Créer :

/find-my-deputy

---

# Interface

Champ :

Entrez votre code postal

Bouton :

Trouver mon député

---

# Validation Flutter

Accepter uniquement :

5 chiffres

---

# Résultat

Afficher :

* photo
* prénom
* nom
* profession
* groupe
* présence
* loyauté
* participation

---

# Derniers votes

Afficher :

5 derniers votes

Navigation vers :

/scrutins/{id}

---

# Dashboard

Ajouter une carte :

Trouver mon député

---

# États

Empty :

Entrez votre code postal.

Not Found :

Aucun représentant trouvé.

Error :

Une erreur est survenue.

Success :

Afficher :

* député
* circonscription
* institution
* derniers votes

---

# Documentation

Créer :

docs/features/find-my-deputy.md

---

# Critère de validation

L'utilisateur peut :

* saisir un code postal
* trouver son représentant
* consulter sa fiche
* voir ses derniers votes
* accéder aux scrutins associés

La fonctionnalité doit être compatible avec l'ajout futur :

* Sénat
* Parlement européen

sans refonte du modèle de données.
