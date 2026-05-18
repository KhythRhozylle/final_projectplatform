FROM php:8.3-fpm as builder

WORKDIR /app

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    nodejs \
    npm \
    nginx \
    && docker-php-ext-install pdo pdo_mysql \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER=1

COPY composer.json composer.lock ./

RUN composer install --no-interaction --no-scripts --optimize-autoloader

COPY . .

RUN if [ ! -f /app/.env ]; then \
    echo "APP_ENV=prod\nAPP_DEBUG=0\nAPP_SECRET=ChangeMe\n" > /app/.env; \
    fi

RUN composer install --no-interaction --optimize-autoloader --no-ansi

RUN php bin/console importmap:install --no-interaction || true

RUN mkdir -p var/cache var/log

# IMPORTANT FIX
RUN chmod -R 777 var

RUN php bin/console cache:clear --env=prod || true
RUN php bin/console cache:warmup --env=prod || true


FROM php:8.3-fpm as runtime

WORKDIR /app

RUN apt-get update && apt-get install -y \
    nginx \
    curl \
    && docker-php-ext-install pdo pdo_mysql \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app /app

# IMPORTANT FIX
RUN mkdir -p /app/var/cache /app/var/log \
    && chmod -R 777 /app/var \
    && chown -R www-data:www-data /app

COPY nginx-main.conf /etc/nginx/nginx.conf

RUN rm -rf /etc/nginx/conf.d/* \
    /etc/nginx/sites-enabled \
    /etc/nginx/sites-available

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]