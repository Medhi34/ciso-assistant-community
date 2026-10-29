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
- **Statut Netlify CLI**:
  - Netlify CLI est opérationnel dans l'environnement.
  - La session Netlify n'est pas encore connectée localement (`Not logged in`).
  - Deux chemins simples permettent de finaliser la liaison : soit la connexion interactive `npx netlify-cli login`, soit l'importation directe du dépôt GitHub `Medhi34/ciso-assistant-community` sur le tableau de bord Netlify.
