#!/bin/bash
set -e

echo "🔨 Building Mzizination for production..."

# CRITICAL: Create .env from .env.example if it doesn't exist
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file from .env.example..."
    if [ ! -f ".env.example" ]; then
        echo "❌ ERROR: .env.example not found! Creating basic .env..."
        cat > .env << 'EOF'
APP_NAME=Mzizination
APP_ENV=production
APP_DEBUG=false
APP_URL=https://mzizination2.onrender.com
DB_CONNECTION=pgsql
CACHE_DRIVER=array
SESSION_DRIVER=cookie
LOG_CHANNEL=stack
LOG_LEVEL=debug
EOF
    else
        cp .env.example .env
    fi
fi

# Generate APP_KEY if empty or missing
if ! grep -q "APP_KEY=base64:" .env; then
    echo "🔑 Generating APP_KEY..."
    php artisan key:generate --force || true
fi

# Clear any cached config that might break things
echo "🧹 Clearing caches..."
rm -rf bootstrap/cache/*.php 2>/dev/null || true

# Install PHP dependencies
echo "📦 Installing PHP dependencies..."
composer install --no-interaction --prefer-dist --optimize-autoloader 2>&1 | tail -20

# Install Node dependencies
if [ -f "package.json" ]; then
    echo "📦 Installing Node dependencies..."
    npm install --production 2>&1 | tail -10
    echo "🎨 Building frontend assets..."
    npm run build || npm run prod || true
fi

# Set permissions
echo "🔐 Setting permissions..."
mkdir -p storage/logs storage/framework/{sessions,views,cache} bootstrap/cache
chmod -R 755 storage bootstrap/cache 2>/dev/null || true

echo "✅ Build complete!"
