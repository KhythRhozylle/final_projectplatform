FROM php:8.3-fpm as builder

WORKDIR /app

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    nodejs \
    npm \
    libicu-dev \
    && docker-php-ext-install pdo pdo_mysql intl \
    && rm -rf /var/lib/apt/lists/*

# THE FIX: We bypass curl entirely and copy the pre-compiled binary
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER=1

COPY composer.json composer.lock ./

RUN composer install --no-interaction --no-scripts --optimize-autoloader

COPY . .
COPY .env.example .env

# Placeholder values for build-time console commands (runtime overrides via compose/Railway)
ENV APP_ENV=prod \
    APP_DEBUG=0 \
    APP_SECRET=build-time-secret-replace-at-runtime \
    DATABASE_URL="mysql://build:build@127.0.0.1:3306/build?serverVersion=8.0.32&charset=utf8mb4"

RUN composer install --no-interaction --optimize-autoloader --no-ansi
RUN php bin/console importmap:install --no-interaction
RUN php bin/console cache:warmup --env=prod --no-debug

FROM php:8.3-fpm as runtime

WORKDIR /app

RUN apt-get update && apt-get install -y \
    nginx \
    curl \
    libicu-dev \
    && docker-php-ext-install pdo pdo_mysql intl opcache \
    && rm -rf /var/lib/apt/lists/*

COPY docker/php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

COPY --from=builder /app /app

RUN mkdir -p /app/var && \
    chown -R www-data:www-data /app && \
    chmod -R 755 /app && \
    chmod -R 775 /app/var

COPY nginx-main.conf /etc/nginx/nginx.conf

RUN rm -rf /etc/nginx/conf.d/* /etc/nginx/sites-enabled /etc/nginx/sites-available
COPY nginx.conf /etc/nginx/conf.d/symfony.conf

COPY entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]