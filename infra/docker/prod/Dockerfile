FROM composer:2 AS composer_deps

WORKDIR /app

COPY api/composer.json api/composer.lock ./

RUN composer install \
    --no-dev \
    --no-interaction \
    --no-progress \
    --prefer-dist \
    --no-scripts \
    --optimize-autoloader

FROM node:22-bookworm-slim AS asset_builder

WORKDIR /app

COPY api/package.json ./

RUN npm install --ignore-scripts

COPY api/resources ./resources
COPY api/public ./public
COPY api/vite.config.js ./vite.config.js

RUN npm run build

FROM php:8.4-fpm-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libpq-dev \
    nginx \
    unzip \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && docker-php-ext-install pdo_pgsql \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /etc/nginx/sites-enabled/default

# Keep enough headroom for large initial sync jobs (scrutins/votes) in cron/worker contexts.
RUN printf "memory_limit=512M\n" > /usr/local/etc/php/conf.d/zz-memory-limit.ini

WORKDIR /var/www/html

COPY api/artisan ./artisan
COPY api/app ./app
COPY api/bootstrap ./bootstrap
COPY api/config ./config
COPY api/database ./database
COPY api/public ./public
COPY api/resources ./resources
COPY api/routes ./routes
COPY api/composer.json ./composer.json
COPY api/package.json ./package.json
COPY api/vite.config.js ./vite.config.js
COPY --from=composer_deps /app/vendor ./vendor
COPY --from=asset_builder /app/public/build ./public/build
COPY infra/docker/prod/nginx.conf /etc/nginx/conf.d/default.conf
COPY infra/docker/prod/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN mkdir -p \
    storage/app/public \
    storage/framework/cache/data \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs \
    bootstrap/cache \
    && rm -f bootstrap/cache/*.php \
    && chmod +x /usr/local/bin/entrypoint.sh \
    && chown -R www-data:www-data storage bootstrap/cache \
    && php artisan package:discover --ansi

EXPOSE 80

CMD ["/usr/local/bin/entrypoint.sh"]