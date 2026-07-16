#!/bin/sh

set -eu

cd /var/www/html

php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan event:cache
php artisan view:cache

php-fpm -D
exec nginx -g 'daemon off;'