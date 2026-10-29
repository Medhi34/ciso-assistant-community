FROM ghcr.io/intuitem/ciso-assistant-community/backend:latest

# Copy our customized settings and startup scripts
COPY backend/ciso_assistant/settings.py /code/ciso_assistant/settings.py
COPY backend/core/startup.py /code/core/startup.py
COPY backend/startup.sh /code/startup.sh
COPY db/ciso-assistant.sqlite3 /code/db/ciso-assistant.sqlite3

RUN chmod +x /code/startup.sh && chmod -R 777 /code/db

EXPOSE 8000
ENTRYPOINT ["uv", "run", "bash", "startup.sh"]
