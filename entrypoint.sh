#!/bin/bash
set -e

mkdir -p /app/var/cache /app/var/log /app/var/share
chown -R www-data:www-data /app/var
chmod -R 775 /app/var

APP_ENV="${APP_ENV:-prod}"
APP_DEBUG="${APP_DEBUG:-0}"

echo "Running database migrations..."
php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration

if [ "$APP_ENV" = "prod" ]; then
  echo "Warming production cache..."
  php bin/console cache:clear --env=prod --no-debug
  php bin/console cache:warmup --env=prod --no-debug
fi

echo "Starting PHP-FPM..."
php-fpm -F &
PHP_PID=$!

echo "Waiting for PHP-FPM to start..."
sleep 2

echo "Starting Nginx..."
nginx -g "daemon off;"

wait $PHP_PID
