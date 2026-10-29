#!/usr/bin/env bash
# wait for database to be ready
if [ ! -n "$DJANGO_SETTINGS_MODULE" ]; then
  export DJANGO_SETTINGS_MODULE=ciso_assistant.settings
fi
mkdir -p db
if [ ! -n "$DJANGO_SECRET_KEY" ]; then
  if [ ! -f db/django_secret_key ]; then
    openssl rand -hex 32 | install -m 600 /dev/stdin db/django_secret_key
    echo "generating initial Django secret key"
  fi
  export DJANGO_SECRET_KEY=$(<db/django_secret_key)
  echo "Django secret key read from file"
fi
# Check database and apply any pending migrations
python manage.py migrate --settings="${DJANGO_SETTINGS_MODULE}" --noinput || { echo "ERROR: database migration failed (see traceback above); backend not started" >&2; exit 1; }

# Skip heavy library parsing if libraries were pre-loaded during build
if [ ! -f db/libraries_loaded ]; then
  echo "Loading built-in libraries into database..."
  python manage.py storelibraries --settings="${DJANGO_SETTINGS_MODULE}" && touch db/libraries_loaded || echo "WARNING: storing built-in libraries failed" >&2
else
  echo "Built-in libraries already initialized."
fi

if [ -n "$DJANGO_SUPERUSER_EMAIL" ]; then
  python manage.py createsuperuser --noinput --settings="${DJANGO_SETTINGS_MODULE}" 2>/dev/null || echo "Superuser check completed."
fi

# Set optimized Gunicorn configuration for 512MB RAM cloud environments (1 worker + 2 threads)
GUNICORN_WORKERS=${GUNICORN_WORKERS:-1}
GUNICORN_THREADS=${GUNICORN_THREADS:-2}
GUNICORN_TIMEOUT=${GUNICORN_TIMEOUT:-120}
GUNICORN_KEEPALIVE=${GUNICORN_KEEPALIVE:-30}
GUNICORN_LIMIT_REQUEST_LINE=${GUNICORN_LIMIT_REQUEST_LINE:-5120}
GUNICORN_PORT=${PORT:-8000}

echo "Starting Gunicorn on port $GUNICORN_PORT with $GUNICORN_WORKERS worker(s) and $GUNICORN_THREADS thread(s)..."

exec gunicorn --chdir ciso_assistant \
  --bind :$GUNICORN_PORT \
  --timeout $GUNICORN_TIMEOUT \
  --keep-alive $GUNICORN_KEEPALIVE \
  --workers=$GUNICORN_WORKERS \
  --threads=$GUNICORN_THREADS \
  --worker-class=gthread \
  --max-requests=500 \
  --max-requests-jitter=50 \
  --limit-request-line=$GUNICORN_LIMIT_REQUEST_LINE \
  --env RUN_MAIN=true \
  ciso_assistant.wsgi:application
