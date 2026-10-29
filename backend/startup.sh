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
RETRY_COUNT=0
while ! python manage.py showmigrations iam; do
  echo "database not ready; waiting ($RETRY_COUNT/10)"
  RETRY_COUNT=$((RETRY_COUNT+1))
  if [ $RETRY_COUNT -ge 10 ]; then
    echo "ERROR: Database check failed repeatedly" >&2
    exit 1
  fi
  sleep 5
done
python manage.py migrate --settings="${DJANGO_SETTINGS_MODULE}" || { echo "ERROR: database migration failed (see traceback above); backend not started, fix the error then restart the container" >&2; exit 1; }
python manage.py storelibraries --settings="${DJANGO_SETTINGS_MODULE}" || echo "WARNING: storing built-in libraries failed (see traceback above); backend starting anyway, new or updated libraries may be missing" >&2
if [ -n "$DJANGO_SUPERUSER_EMAIL" ]; then
  python manage.py createsuperuser --noinput --settings="${DJANGO_SETTINGS_MODULE}"
fi

# Set default values for Gunicorn configuration
GUNICORN_WORKERS=${GUNICORN_WORKERS:-3}
GUNICORN_TIMEOUT=${GUNICORN_TIMEOUT:-100}
GUNICORN_KEEPALIVE=${GUNICORN_KEEPALIVE:-30}
GUNICORN_LIMIT_REQUEST_LINE=${GUNICORN_LIMIT_REQUEST_LINE:-5120}
GUNICORN_PORT=${PORT:-8000}

exec gunicorn --chdir ciso_assistant \
  --bind :$GUNICORN_PORT \
  --timeout $GUNICORN_TIMEOUT \
  --keep-alive $GUNICORN_KEEPALIVE \
  --workers=$GUNICORN_WORKERS \
  --limit-request-line=$GUNICORN_LIMIT_REQUEST_LINE \
  --env RUN_MAIN=true \
  ciso_assistant.wsgi:application
