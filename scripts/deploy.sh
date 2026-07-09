#!/bin/sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
API_DIR="$SCRIPT_DIR/../api"

cd "$API_DIR"

composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

php artisan migrate --force

if [ ! -L public/storage ]; then
    php artisan storage:link
fi

php artisan optimize
php artisan config:cache
php artisan route:cache
php artisan event:cache
php artisan view:cache