# Plan de Déploiement Netlify - CISO Assistant

## Objectif
Adapter et préparer l'application CISO Assistant (particulièrement le frontend SvelteKit et la configuration d'orchestration) pour un déploiement complet sur Netlify, configurer les redirections API / reverse proxy vers le backend, paramétrer le sous-domaine `ciso.netlify.app`, et fournir les mécanismes de build, test local et déploiement Netlify (CLI et CI/CD).

## Phases

- [x] **Phase 1: Diagnostic et Analyse de l'existant**
  - Analyser la structure du frontend SvelteKit, des dépendances, et des configurations de build (`package.json`, `svelte.config.js`, `vite.config.ts`).
  - Identifier le rôle de Netlify (Frontend SSR/CDN) et les limitations (le Backend Django/Huey/Qdrant nécessite un serveur distant).
  - Découverte clé: `CISO_ASSISTANT_URL=https://ciso.netlify.app` doit être configuré côté backend pour le CSRF Django.

- [x] **Phase 2: Configuration de l'adaptateur Netlify pour SvelteKit**
  - Ajout de `@sveltejs/adapter-netlify` dans `frontend/package.json`.
  - Mise à jour de `frontend/svelte.config.js` avec détection conditionnelle `NETLIFY=true` / `ADAPTER=netlify` et fallback sécurisé `adapterNode`.
  - Création de `netlify.toml` à la racine et dans `frontend/` avec headers de sécurité, bundler esbuild et règles de redirection d'API.

- [x] **Phase 3: Validation du build local Netlify**
  - Téléchargement et installation des dépendances dans `frontend/` avec `pnpm` (798 paquets installés).
  - Test de compilation (`pnpm run build`) avec l'adaptateur Netlify activé (`NETLIFY=true`).
  - Validation des artefacts générés :
    - Assets statiques et chunks CDN dans `frontend/.svelte-kit/netlify`
    - Fonction de rendu serverless AWS Lambda dans `frontend/.netlify/functions-internal/sveltekit-render.mjs`

- [x] **Phase 4: Automatisation et Déploiement**
  - Création de `deploy-netlify.ps1` (script PowerShell prêt à l'emploi avec gestion du site `ciso`, backend URL, et envoi simultané des assets et fonctions serverless).
  - Création de `deploy-netlify.sh` (script Bash pour Linux/CI).
  - Création du workflow GitHub Actions `.github/workflows/deploy-netlify.yml` pour déploiement CI/CD automatique.
  - Création du guide complet `NETLIFY_DEPLOYMENT.md`.
