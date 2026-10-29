FROM ghcr.io/intuitem/ciso-assistant-community/backend:latest

COPY backend/ciso_assistant/settings.py /code/ciso_assistant/settings.py
COPY backend/core/startup.py /code/core/startup.py
COPY backend/startup.sh /code/startup.sh

RUN chmod +x /code/startup.sh

# Pre-migrate and initialize SQLite DB so container boots in seconds on Render
ENV DJANGO_SETTINGS_MODULE=ciso_assistant.settings \
    DJANGO_SECRET_KEY=build-time-secret-key-32-chars-long-12345 \
    ALLOWED_HOSTS=*

RUN mkdir -p /code/db && \
    uv run python manage.py migrate --noinput && \
    uv run python manage.py storelibraries && \
    chmod -R 777 /code/db

EXPOSE 8000
ENTRYPOINT ["uv", "run", "bash", "startup.sh"]
