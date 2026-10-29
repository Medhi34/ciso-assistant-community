# Guide de Déploiement CISO Assistant sur Netlify

Ce guide détaille la mise en production du portail web **CISO Assistant** sur **Netlify** avec le nom de domaine cible `ciso.netlify.app`.

---

## 1. Comprendre l'Architecture Découplée

**CISO Assistant** est composé de deux composants majeurs :
1. **Frontend (SvelteKit)** : Interface utilisateur moderne avec rendu côté serveur (SSR), internationalisation (Paraglide), composants Skeleton UI et Tailwind CSS.
2. **Backend (Python / Django REST Framework)** : Moteur métier, base de données (SQLite/PostgreSQL), workers asynchrones (Huey), et moteur vectoriel (Qdrant).

### Rôle de Netlify
Netlify héberge le **Frontend SvelteKit** :
- Les pages statiques et assets sont servis sur le CDN mondial Netlify.
- Les routes dynamiques et le SSR sont exécutés via des **Netlify Serverless Functions**.
- Les appels API (`/api/*`) sont automatiquement routés vers votre instance Backend distante.

> **Important** : L'API Backend doit tourner sur un serveur connecté à Internet (VPS, conteneur cloud, AWS, OVH, etc.) pour que l'application puisse authentifier les utilisateurs et sauvegarder les données.

---

## 2. Configuration Déjà Mise en Place dans le Répertoire

Les fichiers suivants ont été créés et configurés :

| Fichier | Rôle |
|---|---|
| `netlify.toml` | Configuration racine pour le build Netlify, réécriture `/api/*`, headers de sécurité |
| `frontend/netlify.toml` | Configuration locale spécifique au frontend |
| `frontend/svelte.config.js` | Détection dynamique de l'environnement Netlify (`@sveltejs/adapter-netlify`) avec fallback `@sveltejs/adapter-node` |
| `deploy-netlify.ps1` | Script PowerShell automatisé pour déployer directement depuis Windows |
| `deploy-netlify.sh` | Script Bash automatisé pour Linux/macOS/CI |
| `.github/workflows/deploy-netlify.yml` | Pipeline GitHub Actions pour déploiement automatique sur Netlify |

---

## 3. Méthode 1 : Déploiement via le script PowerShell (Recommandé sous Windows)

### Prérequis
- Un compte gratuit sur [Netlify.com](https://app.netlify.com).
- Un token d'authentification personnel Netlify (généré dans **User Settings > Applications > New access token**).

### Commande de déploiement

Exécutez dans votre terminal PowerShell :

```powershell
# Déploiement direct avec votre token Netlify et l'URL de votre API backend
.\deploy-netlify.ps1 -SiteName "ciso" -BackendUrl "https://api-ciso.votre-domaine.com/api" -AuthToken "VOTRE_NETLIFY_TOKEN"
```

Si vous préférez vous connecter interactivement dans le navigateur :
```powershell
npx netlify-cli login
.\deploy-netlify.ps1 -SiteName "ciso" -BackendUrl "https://api-ciso.votre-domaine.com/api"
```

> **Note sur le nom de domaine `ciso.netlify.app`** :
> Les sous-domaines `*.netlify.app` sont uniques mondialement. Si le nom `ciso` est déjà pris par un autre utilisateur sur Netlify, spécifiez une variante comme :
> ```powershell
> .\deploy-netlify.ps1 -SiteName "ciso-camwater" -BackendUrl "https://..."
> ```
> Vous pourrez ensuite lier n'importe quel domaine ou sous-domaine personnalisé (ex: `ciso.camwater.cm`).

---

## 4. Méthode 2 : Déploiement Continu via GitHub Actions

Si votre projet est hébergé sur GitHub :

1. Allez dans les paramètres de votre dépôt GitHub (**Settings > Secrets and variables > Actions**).
2. Ajoutez les secrets suivants :
   - `NETLIFY_AUTH_TOKEN` : Votre token d'accès Netlify.
   - `NETLIFY_SITE_ID` *(optionnel)* : L'ID du site Netlify créé.
3. Définissez la variable de dépôt :
   - `PUBLIC_BACKEND_API_URL` : L'URL de votre API backend (ex: `https://api-ciso.votre-domaine.com/api`).
4. Déclenchez le workflow manuellement dans **Actions > Deploy CISO Assistant to Netlify > Run workflow** ou poussez sur la branche `main`.

---

## 5. Méthode 3 : Connexion Directe depuis le Dashboard Netlify

1. Connectez-vous à [Netlify](https://app.netlify.com).
2. Cliquez sur **Add new site** > **Import an existing project** > **GitHub / GitLab**.
3. Sélectionnez le dépôt `ciso-assistant-community`.
4. Netlify détecte automatiquement `netlify.toml` avec les réglages suivants :
   - **Base directory** : `frontend`
   - **Build command** : `pnpm run build`
   - **Publish directory** : `frontend/.svelte-kit/netlify`
5. Dans la section **Environment variables**, ajoutez :
   - `PUBLIC_BACKEND_API_URL` = `https://api-ciso.votre-domaine.com/api`
   - `PUBLIC_BACKEND_API_EXPOSED_URL` = `https://api-ciso.votre-domaine.com/api`
   - `NETLIFY` = `true`
   - `ADAPTER` = `netlify`
6. Cliquez sur **Deploy site**.
7. Dans **Site configuration > Site details > Change site name**, entrez `ciso` pour obtenir `ciso.netlify.app`.

---

## 6. Configuration Requise Côté Backend (Indispensable)

Sur votre serveur hébergeant le Backend Django (ex: dans `docker-compose.yml` ou les variables du serveur) :
- Définissez :
  ```env
  CISO_ASSISTANT_URL=https://ciso.netlify.app
  ALLOWED_HOSTS=backend,localhost,api.votre-domaine.com
  ```
  *Explication : Django valide les tokens CSRF en comparant l'en-tête `Origin` de la requête reçue avec `CSRF_TRUSTED_ORIGINS = [CISO_ASSISTANT_URL]`. Si cette variable n'est pas définie sur votre URL Netlify, les connexions et sauvegardes renverront une erreur `403 Forbidden CSRF verification failed`.*

---

## 7. Vérification et Dépannage

- **Erreur de connexion API** : Assurez-vous que l'URL `PUBLIC_BACKEND_API_URL` est accessible publiquement en HTTPS et que les règles CORS du backend autorisent `https://ciso.netlify.app`.
- **Logs des fonctions** : Consultez l'onglet **Logs > Functions** dans votre tableau de bord Netlify pour inspecter les requêtes SSR du serveur SvelteKit.
