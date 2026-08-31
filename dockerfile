# Build stage
FROM php:8.2-fpm as builder

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    unzip \
    && docker-php-ext-install pdo pdo_mysql pdo_pgsql bcmath \
    && rm -rf /var/lib/apt/lists/*

# Copy Composer from official image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory and copy composer files
COPY composer.json composer.lock* ./

# Install PHP dependencies (use install, not update)
RUN composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --no-scripts

# Copy entire application
COPY . .

# Run Laravel package discovery
RUN php artisan package:discover --ansi

# Runtime stage
FROM php:8.2-fpm

WORKDIR /app

# Install runtime system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    && docker-php-ext-install pdo pdo_mysql pdo_pgsql bcmath \
    && rm -rf /var/lib/apt/lists/*

# Copy built application from builder
COPY --from=builder /app /app

# Set proper permissions
RUN chown -R www-data:www-data /app/storage /app/bootstrap/cache && \
    chmod -R 755 /app/storage /app/bootstrap/cache

# Expose port
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]
