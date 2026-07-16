#!/bin/sh

set -eu

cd /var/www/html

echo "[entrypoint] Starting release tasks"

echo "[entrypoint] Migration status before deploy (best effort)"
php artisan migrate:status --no-interaction || true

echo "[entrypoint] Running migrations"
if ! php artisan migrate --force -vvv; then
	echo "[entrypoint] Migration failed, dumping migration status (best effort)"
	php artisan migrate:status --no-interaction || true
	exit 1
fi

echo "[entrypoint] Building Laravel caches"
php artisan config:cache
php artisan route:cache
php artisan event:cache
php artisan view:cache

echo "[entrypoint] Starting php-fpm and nginx"
php-fpm -D
exec nginx -g 'daemon off;'