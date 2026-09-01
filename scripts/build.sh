#!/bin/bash
set -e

echo "🔨 Building Mzizination for production..."

# Step 1: Check if .env exists, if not create it from .env.example
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file from .env.example..."
    cp .env.example .env
fi

# Step 2: Generate APP_KEY if not already set (Render should set this via envVars)
if grep -q "APP_KEY=$" .env; then
    echo "Generating APP_KEY..."
    php artisan key:generate --force
fi

# Step 3: Clear any cached config that might reference missing keys
rm -rf bootstrap/cache/config.php 2>/dev/null || true

# Step 4: Install PHP dependencies
echo "📦 Installing PHP dependencies..."
composer install --no-interaction --prefer-dist --optimize-autoloader

# Step 5: Install Node dependencies (if using frontend)
if [ -f "package.json" ]; then
    echo "📦 Installing Node dependencies..."
    npm install --production
    # Build frontend assets
    echo "🎨 Building frontend assets..."
    npm run build || npm run prod || true
fi

# Step 6: Set storage permissions
echo "🔐 Setting storage permissions..."
mkdir -p storage/logs storage/framework/{sessions,views,cache}
chmod -R 755 storage bootstrap/cache 2>/dev/null || true

# Step 7: Cache configuration (will happen in post-deploy hook too)
echo "⚙️ Preparing configuration..."
php artisan config:clear || true
php artisan cache:clear || true

echo "✅ Build complete - Laravel is ready for deployment"
