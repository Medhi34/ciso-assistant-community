FROM ghcr.io/intuitem/ciso-assistant-community/backend:latest

COPY backend/ciso_assistant/settings.py /code/ciso_assistant/settings.py
COPY backend/core/startup.py /code/core/startup.py
COPY backend/startup.sh /code/startup.sh

RUN chmod +x /code/startup.sh

# Pre-migrate, load libraries, and initialize superuser so container boots in seconds on Render
ENV DJANGO_SETTINGS_MODULE=ciso_assistant.settings \
    DJANGO_SECRET_KEY=440c55ee-a8d6-4ee7-9ed7-c054d89daaf6-camwater-secret-2026 \
    CISO_ASSISTANT_SUPERUSER_EMAIL=medhi.tombi@camwater.cm \
    CISO_ASSISTANT_SUPERUSER_PASSWORD=Camwater26! \
    DJANGO_SUPERUSER_EMAIL=medhi.tombi@camwater.cm \
    DJANGO_SUPERUSER_PASSWORD=Camwater26! \
    FORCE_CREATE_ADMIN=true \
    ALLOWED_HOSTS=*

RUN mkdir -p /code/db && \
    uv run python manage.py migrate --noinput && \
    uv run python manage.py storelibraries && \
    touch /code/db/libraries_loaded && \
    chmod -R 777 /code/db

EXPOSE 8000
ENTRYPOINT ["uv", "run", "bash", "startup.sh"]
