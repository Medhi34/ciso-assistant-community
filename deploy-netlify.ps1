<#
.SYNOPSIS
    Script de préparation et déploiement de CISO Assistant sur Netlify.
.DESCRIPTION
    Ce script installe les dépendances, compile le frontend SvelteKit avec l'adaptateur Netlify
    et déploie l'application vers Netlify (sous-domaine cible: ciso.netlify.app ou nom personnalisé).
.PARAMETER SiteName
    Nom du site Netlify (par défaut: "ciso"). L'URL résultante sera https://<SiteName>.netlify.app.
.PARAMETER BackendUrl
    URL de l'API backend CISO Assistant (ex: https://api.ciso.mondomaine.com/api).
.PARAMETER AuthToken
    Token d'accès Netlify personnel (ou défini via la variable d'environnement NETLIFY_AUTH_TOKEN).
.PARAMETER Prod
    Déploiement direct en production. Activé par défaut.
#>
param(
    [string]$SiteName = "ciso",
    [string]$BackendUrl = "https://localhost:8443/api",
    [string]$AuthToken = $env:NETLIFY_AUTH_TOKEN,
    [switch]$Prod = $true
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Déploiement de CISO Assistant Frontend sur Netlify    " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Site cible : https://$SiteName.netlify.app" -ForegroundColor Yellow
Write-Host "API Backend : $BackendUrl" -ForegroundColor Yellow
Write-Host ""

# 1. Vérification des prérequis
Write-Host "[1/5] Vérification de l'environnement..." -ForegroundColor Green
if (-not (Get-Command "node" -ErrorAction SilentlyContinue)) {
    Write-Error "Node.js n'est pas installé. Veuillez installer Node.js (version 20+ recommandée)."
    exit 1
}

if (-not (Get-Command "pnpm" -ErrorAction SilentlyContinue)) {
    Write-Host "pnpm n'est pas disponible dans le PATH. Installation temporaire..." -ForegroundColor Yellow
    npm install -g pnpm
}

# 2. Configuration des variables d'environnement
Write-Host "[2/5] Configuration de l'environnement de build..." -ForegroundColor Green
$env:NETLIFY = "true"
$env:ADAPTER = "netlify"
$env:PUBLIC_BACKEND_API_URL = $BackendUrl
$env:PUBLIC_BACKEND_API_EXPOSED_URL = $BackendUrl

# 3. Installation des dépendances et compilation
Write-Host "[3/5] Compilation du frontend SvelteKit avec adaptateur Netlify..." -ForegroundColor Green
Push-Location "frontend"
try {
    pnpm install --frozen-lockfile=false
    pnpm run build
} catch {
    Write-Error "Échec de la compilation du frontend : $_"
    Pop-Location
    exit 1
}
Pop-Location

# 4. Vérification de l'authentification Netlify
Write-Host "[4/5] Préparation des arguments Netlify..." -ForegroundColor Green
$netlifyArgs = @(
    "deploy",
    "--prod",
    "--dir=frontend/.svelte-kit/netlify",
    "--functions=frontend/.netlify/functions-internal"
)

if ($AuthToken) {
    $netlifyArgs += "--auth", $AuthToken
}

if ($SiteName) {
    $netlifyArgs += "--site", $SiteName
}

# 5. Déploiement via Netlify CLI
Write-Host "[5/5] Envoi des artefacts (assets CDN + fonctions serverless) vers Netlify..." -ForegroundColor Green
try {
    npx -y netlify-cli @netlifyArgs
    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host " Déploiement terminé avec succès !" -ForegroundColor Green
    Write-Host " URL: https://$SiteName.netlify.app" -ForegroundColor Cyan
    Write-Host "==========================================================" -ForegroundColor Green
} catch {
    Write-Warning "Le déploiement a rencontré une erreur ou demande une authentification manuelle."
    Write-Host "Si le nom de site '$SiteName' est déjà réservé par un autre utilisateur globalement sur Netlify," -ForegroundColor Yellow
    Write-Host "vous pouvez relancer le script avec un nom unique :" -ForegroundColor Yellow
    Write-Host "  .\deploy-netlify.ps1 -SiteName 'ciso-assistant-votre-nom'" -ForegroundColor White
    Write-Host ""
    Write-Host "Pour vous connecter interactivement à Netlify :" -ForegroundColor Yellow
    Write-Host "  npx -y netlify-cli login" -ForegroundColor White
}
