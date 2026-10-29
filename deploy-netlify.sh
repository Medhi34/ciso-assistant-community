#!/usr/bin/env bash
# ==============================================================================
# Script de déploiement CISO Assistant sur Netlify (Bash)
# ==============================================================================

set -e

SITE_NAME="${1:-ciso}"
BACKEND_URL="${2:-https://localhost:8443/api}"
AUTH_TOKEN="${NETLIFY_AUTH_TOKEN:-$3}"

echo "=========================================================="
echo "   Déploiement de CISO Assistant Frontend sur Netlify    "
echo "=========================================================="
echo "Site cible : https://${SITE_NAME}.netlify.app"
echo "API Backend : ${BACKEND_URL}"
echo ""

# 1. Vérification des prérequis
if ! command -v node &> /dev/null; then
    echo "Erreur: Node.js n'est pas installé."
    exit 1
fi

if ! command -v pnpm &> /dev/null; then
    echo "pnpm introuvable. Installation via npm..."
    npm install -g pnpm
fi

# 2. Variables d'environnement pour le build
export NETLIFY=true
export ADAPTER=netlify
export PUBLIC_BACKEND_API_URL="${BACKEND_URL}"
export PUBLIC_BACKEND_API_EXPOSED_URL="${BACKEND_URL}"

# 3. Compilation
echo "[1/3] Compilation du frontend avec l'adaptateur Netlify..."
cd frontend
pnpm install --frozen-lockfile=false
pnpm run build
cd ..

# 4. Déploiement
echo "[2/3] Déploiement sur Netlify..."
DEPLOY_ARGS="--prod --dir=frontend/.svelte-kit/netlify --functions=frontend/.netlify/functions-internal --site=${SITE_NAME}"
if [ -n "${AUTH_TOKEN}" ]; then
    DEPLOY_ARGS="${DEPLOY_ARGS} --auth=${AUTH_TOKEN}"
fi

npx -y netlify-cli deploy ${DEPLOY_ARGS}

echo "[3/3] Déploiement achevé !"
echo "Consultez : https://${SITE_NAME}.netlify.app"
