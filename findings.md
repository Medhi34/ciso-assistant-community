# Findings & Découvertes - Déploiement Netlify

## Architecture
- **Repository**: Monorepo contenant `frontend/` (SvelteKit), `backend/` (Django REST Framework), `documentation/`, `product-docs/`.
- **Frontend Framework**: SvelteKit 2 avec Vite, Paraglide JS (i18n), Skeleton UI, Tailwind CSS.
- **Adaptateur par défaut**: Actuellement `@sveltejs/adapter-node` (pour conteneur Docker).
- **SSR & Hooks**: Le frontend utilise `hooks.server.ts` pour gérer les requêtes serveur, sessions et communications avec l'API backend (`BASE_API_URL`).
- **Gestionnaire de paquets**: Le projet a un `pnpm-lock.yaml` et `pnpm-workspace.yaml`. Node.js v25.8.1 et npm 11.19.0 sont installés sur la machine. `pnpm` n'est pas installé globalement.
- **Environnement Netlify**: Netlify supporte SvelteKit nativement via `@sveltejs/adapter-netlify` en transformant les routes SSR en fonctions Serverless AWS Lambda et en distribuant les assets statiques sur son CDN.
- **CSRF & Origines autorisées Backend**:
  Dans `backend/ciso_assistant/settings.py`, Django configure `CSRF_TRUSTED_ORIGINS = [CISO_ASSISTANT_URL]`.
  Par conséquent, sur l'instance backend (sur votre VPS/serveur), la variable d'environnement `CISO_ASSISTANT_URL` doit être configurée sur l'URL Netlify :
  `CISO_ASSISTANT_URL=https://ciso.netlify.app`
  afin que les formulaires d'authentification et requêtes mutantes POST/PUT soient autorisés sans erreur CSRF (403 Forbidden).
