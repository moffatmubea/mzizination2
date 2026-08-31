#!/bin/sh
set -e

# Ensure log directory exists
mkdir -p /app/storage/logs

# Start supervisord in the foreground
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
