# Sprint 02 - Fondation Flutter

## Objectif

Créer l'application Flutter et préparer l'architecture du projet.

Aucun écran métier complexe n'est attendu.

L'objectif est uniquement de mettre en place une base saine.

---

## Stack

* Flutter stable
* Material 3
* Dio
* GoRouter
* Riverpod

---

## Structure

Créer :

```text
lib/

core/
├── api/
├── router/
├── theme/
├── widgets/

features/
├── deputies/
├── groups/
├── scrutins/

main.dart
```

---

## API Client

Créer :

```text
core/api/api_client.dart
```

Basé sur Dio.

---

## Configuration

Créer :

```text
core/config/app_config.dart
```

Permettant de définir :

```text
baseUrl
```

---

## Routing

Configurer GoRouter.

Routes :

/
/deputies
/deputies/:slug

/scrutins
/scrutins/:id

````

---

## Theme

Créer un thème Material 3 minimal.

---

## Écran d'accueil

Créer un écran simple :

```text
VoteClair
````

avec navigation vers :

* Députés
* Scrutins

---

## Critère de validation

L'application démarre.

La navigation fonctionne.

Aucun appel API réel n'est encore nécessaire.
