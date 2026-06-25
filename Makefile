SHELL := /bin/bash

DOCKER := docker
COMPOSE := docker compose
LARAVEL_SERVICE := laravel

FLUTTER_DIR := mobile
API_BASE_URL ?= http://localhost:8000/api
DEVICE ?=

.PHONY: help up down restart logs ps build shell install keygen migrate fresh test queue-worker sync sync-status sync-failed sync-retry sync-flush mobile-deps mobile-run mobile-run-android mobile-analyze mobile-test mobile-clean

help:
	@echo "VoteClair Makefile"
	@echo ""
	@echo "Docker / Laravel:"
	@echo "  make up              - Lancer la stack Docker"
	@echo "  make down            - Arreter la stack Docker"
	@echo "  make restart         - Redemarrer la stack"
	@echo "  make logs            - Suivre les logs de la stack"
	@echo "  make ps              - Voir les services"
	@echo "  make build           - Rebuild des images"
	@echo "  make shell           - Shell dans le conteneur Laravel"
	@echo "  make install         - composer install"
	@echo "  make keygen          - php artisan key:generate"
	@echo "  make migrate         - php artisan migrate"
	@echo "  make fresh           - php artisan migrate:fresh --seed"
	@echo "  make test            - php artisan test"
	@echo "  make queue-worker    - Worker queue Redis (sync)"
	@echo "  make sync            - Lancer voteclair:sync"
	@echo "  make sync-status     - Voir l'etat incremental"
	@echo "  make sync-failed     - Voir les jobs echoues"
	@echo "  make sync-retry      - Retry jobs echoues"
	@echo "  make sync-flush      - Vider failed jobs"
	@echo ""
	@echo "Mobile Flutter:"
	@echo "  make mobile-deps     - flutter pub get"
	@echo "  make mobile-run      - Lancer l'app en local"
	@echo "  make mobile-run-android - Lancer pour emulateur Android (10.0.2.2)"
	@echo "  make mobile-analyze  - flutter analyze"
	@echo "  make mobile-test     - flutter test"
	@echo "  make mobile-clean    - flutter clean"
	@echo ""
	@echo "Variables utiles:"
	@echo "  API_BASE_URL=$(API_BASE_URL)"
	@echo "  DEVICE=$(DEVICE)"
	@echo ""
	@echo "Exemples:"
	@echo "  make mobile-run DEVICE=chrome"
	@echo "  make mobile-run API_BASE_URL=http://127.0.0.1:8000/api"

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

restart: down up

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

build:
	$(COMPOSE) up -d --build

shell:
	$(COMPOSE) exec $(LARAVEL_SERVICE) bash

install:
	$(COMPOSE) exec $(LARAVEL_SERVICE) composer install

keygen:
	$(COMPOSE) exec $(LARAVEL_SERVICE) php artisan key:generate

migrate:
	$(COMPOSE) exec $(LARAVEL_SERVICE) php artisan migrate

fresh:
	$(COMPOSE) exec $(LARAVEL_SERVICE) php artisan migrate:fresh --seed

test:
	$(COMPOSE) exec $(LARAVEL_SERVICE) php artisan test

queue-worker:
	$(COMPOSE) exec $(LARAVEL_SERVICE) php artisan queue:work redis --queue=sync --tries=3 --timeout=0

sync:
	$(COMPOSE) exec $(LARAVEL_SERVICE) php artisan voteclair:sync

sync-status:
	$(COMPOSE) exec $(LARAVEL_SERVICE) php artisan voteclair:sync-status

sync-failed:
	$(COMPOSE) exec $(LARAVEL_SERVICE) php artisan queue:failed

sync-retry:
	$(COMPOSE) exec $(LARAVEL_SERVICE) php artisan queue:retry all

sync-flush:
	$(COMPOSE) exec $(LARAVEL_SERVICE) php artisan queue:flush

mobile-deps:
	cd $(FLUTTER_DIR) && flutter pub get

mobile-run:
	cd $(FLUTTER_DIR) && flutter run $(if $(DEVICE),-d $(DEVICE),) --dart-define=API_BASE_URL=$(API_BASE_URL)

mobile-run-android:
	cd $(FLUTTER_DIR) && flutter run $(if $(DEVICE),-d $(DEVICE),) --dart-define=API_BASE_URL=http://10.0.2.2:8000/api

mobile-analyze:
	cd $(FLUTTER_DIR) && flutter analyze

mobile-test:
	cd $(FLUTTER_DIR) && flutter test

mobile-clean:
	cd $(FLUTTER_DIR) && flutter clean
