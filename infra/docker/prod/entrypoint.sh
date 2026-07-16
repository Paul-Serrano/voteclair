#!/bin/sh

set -eu

cd /var/www/html

MIGRATION_CONNECTION="${MIGRATION_DB_CONNECTION:-${DB_CONNECTION:-pgsql}}"

if [ "$MIGRATION_CONNECTION" = "pgsql" ] && [ -n "${DB_HOST:-}" ] && echo "${DB_HOST}" | grep -q -- '-pooler\.'; then
	echo "[entrypoint] WARNING: DB_HOST points to a Neon pooler endpoint."
	echo "[entrypoint] WARNING: Use MIGRATION_DB_CONNECTION=pgsql_direct with DB_DIRECT_* vars for migrations."
fi

echo "[entrypoint] Starting release tasks"
echo "[entrypoint] Migration connection: $MIGRATION_CONNECTION"

echo "[entrypoint] Migration status before deploy (best effort)"
php artisan migrate:status --database="$MIGRATION_CONNECTION" --no-interaction || true

echo "[entrypoint] Running migrations"
if ! php artisan migrate --database="$MIGRATION_CONNECTION" --force -vvv; then
	echo "[entrypoint] Migration failed, dumping migration status (best effort)"
	php artisan migrate:status --database="$MIGRATION_CONNECTION" --no-interaction || true
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