# Findings & Découvertes - Déploiement Netlify

## Architecture
- **Repository**: Monorepo contenant `frontend/` (SvelteKit), `backend/` (Django REST Framework), `documentation/`, `product-docs/`.
- **Frontend Framework**: SvelteKit 2 avec Vite, Paraglide JS (i18n), Skeleton UI, Tailwind CSS.
- **Adaptateur par défaut**: Actuellement `@sveltejs/adapter-node` (pour conteneur Docker).
- **SSR & Hooks**: Le frontend utilise `hooks.server.ts` pour gérer les requêtes serveur, sessions et communications avec l'API backend (`BASE_API_URL`).
- **Gestionnaire de paquets**: Le projet a un `pnpm-lock.yaml` et `pnpm-workspace.yaml`. Node.js v25.8.1 et npm 11.19.0 sont installés sur la machine. `pnpm` n'est pas installé globalement.
- **Environnement Netlify**: Netlify supporte SvelteKit nativement via `@sveltejs/adapter-netlify` en transformant les routes SSR en fonctions Serverless AWS Lambda et en distribuant les assets statiques sur son CDN.
- **Accès GitHub & Fork Automatisé**:
  - Les identifiants GitHub de l'utilisateur (`Medhi34`) ont été récupérés via le gestionnaire de crédentiels Windows avec les permissions complètes (`repo`, `workflow`, `gist`).
  - Le fork du dépôt a été créé avec succès sur GitHub : `https://github.com/Medhi34/ciso-assistant-community`.
  - Les branches `main` et `deploy-netlify` ont été synchronisées et poussées avec toutes les configurations Netlify.
  - Le workflow GitHub Actions `Deploy CISO Assistant to Netlify` est activé et prêt.
- **Résolution du build Netlify (Node 22 requis par pnpm)**:
  - Le log d'échec Netlify a révélé l'erreur : `warn: This version of pnpm requires at least Node.js v22.13` et `Error [ERR_UNKNOWN_BUILTIN_MODULE]: No such built-in module: node:sqlite`.
  - En effet, `pnpm@11.24.0` utilise le module natif `node:sqlite` apparu dans Node.js 22+.
  - Correction : Passage de Node 20 à Node 22 dans `.nvmrc`, `frontend/.nvmrc`, `netlify.toml` et `frontend/netlify.toml`.
- **Résolution des échecs Plumber GitHub**:
  - Les anciens runs échouaient car Plumber vérifiait la protection de branche sur `main`.
  - Le workflow `.github/workflows/plumber.yml` a été restreint à `intuitem/ciso-assistant-community` uniquement (`if: github.repository == 'intuitem/ciso-assistant-community'`).
  - Résultat : Les runs Plumber sur votre fork `Medhi34/ciso-assistant-community` sont désormais marqués `skipped` sans aucune erreur.
