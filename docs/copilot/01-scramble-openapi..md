# Sprint 01 - Documentation OpenAPI

## Objectif

Documenter automatiquement l'API VoteClair.

L'objectif est de :

* Visualiser les endpoints
* Tester l'API rapidement
* Préparer l'intégration Flutter
* Générer une documentation technique

---

## Package

Installer :

```bash
composer require dedoc/scramble
```

---

## Configuration

Publier la configuration si nécessaire.

La documentation devra être accessible sur :

```text
/api/documentation
```

---

## Contraintes

Tous les endpoints existants doivent apparaître :

* GET /api/deputies

* GET /api/deputies/{slug}

* GET /api/deputies/{slug}/votes

* GET /api/groups

* GET /api/scrutins

* GET /api/scrutins/{id}

* GET /api/scrutins/{id}/votes

---

## Documentation

Ajouter les annotations PHP nécessaires dans les controllers.

Documenter :

* paramètres
* pagination
* réponses JSON

---

## Critère de validation

Lorsque :

```text
/api/documentation
```

est accessible et que tous les endpoints sont visibles et testables.
