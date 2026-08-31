release: php artisan migrate --force
web: php artisan serve --host=0.0.0.0 --port=$PORT
web: docker-php-ext-install pdo pdo_pgsql && nginx -g "daemon off;"
