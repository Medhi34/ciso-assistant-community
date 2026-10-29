FROM ghcr.io/intuitem/ciso-assistant-community/backend:latest

# Copy customized settings and startup scripts with automatic superuser provisioning
COPY backend/ciso_assistant/settings.py /code/ciso_assistant/settings.py
COPY backend/core/startup.py /code/core/startup.py
COPY backend/startup.sh /code/startup.sh

RUN chmod +x /code/startup.sh

EXPOSE 8000
ENTRYPOINT ["uv", "run", "bash", "startup.sh"]
