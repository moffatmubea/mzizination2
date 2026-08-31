# Multi-stage build for Mzizination
# Stage 1: Build stage
FROM php:8.2-fpm-alpine as builder
# Install system dependencies
RUN apk add --no-cache \
    curl \
    git \
    libpq-dev \
    postgresql-client \
    zip \
    unzip
# Install PHP extensions
RUN docker-php-ext-install pdo pdo_pgsql
# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
WORKDIR /app
# Copy composer files
COPY composer.json composer.lock* ./
# Install PHP dependencies
# Use composer update to regenerate lock file if composer.json was updated
RUN composer update --no-interaction --prefer-dist --optimize-autoloader
# Stage 2: Runtime stage
FROM php:8.2-fpm-alpine
# Install runtime dependencies
# IMPORTANT: postgresql-dev is needed to compile pdo_pgsql
RUN apk add --no-cache \
    curl \
    libpq \
    libpq-dev \
    nginx \
    supervisor
# Install PHP extensions
RUN docker-php-ext-install pdo pdo_pgsql
# Copy PHP configuration
COPY docker/php.ini /usr/local/etc/php/php.ini
COPY docker/www.conf /usr/local/etc/php-fpm.d/www.conf
# Copy nginx and supervisor configs
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/supervisord.conf /etc/supervisor/supervisord.conf
# Copy entrypoint script
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
# Copy application
COPY --from=builder /app /app
COPY . /app
WORKDIR /app
# Create necessary directories
RUN mkdir -p storage/logs storage/cache bootstrap/cache \
    && chown -R www-data:www-data /app/storage /app/bootstrap
# Expose port
EXPOSE 8000
# Start supervisor (which manages nginx + php-fpm)
ENTRYPOINT ["/entrypoint.sh"]
CMD []
