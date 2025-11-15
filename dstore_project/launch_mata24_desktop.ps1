# MATA24 Desktop Launcher
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "        MATA24 - APPLICATION DESKTOP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier si nous sommes dans le bon dossier
if (-not (Test-Path "build\web\index.html")) {
    Write-Host "ERREUR: Fichiers de l'application non trouvés." -ForegroundColor Red
    Write-Host "Assurez-vous d'exécuter ce script depuis le dossier mata24." -ForegroundColor Red
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}

Write-Host "Lancement de l'application MATA24..." -ForegroundColor Green
Write-Host ""

# Aller dans le dossier build/web
Set-Location "build\web"

# Vérifier si Python est disponible
try {
    $pythonVersion = python --version 2>&1
    Write-Host "Python détecté: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "ERREUR: Python n'est pas installé ou n'est pas dans le PATH." -ForegroundColor Red
    Write-Host "Veuillez installer Python depuis https://python.org" -ForegroundColor Yellow
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}

Write-Host ""
Write-Host "Démarrage du serveur local..." -ForegroundColor Yellow
Write-Host "L'application sera disponible à l'adresse: http://localhost:8080" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT:" -ForegroundColor Yellow
Write-Host "- Gardez cette fenêtre ouverte pendant l'utilisation" -ForegroundColor White
Write-Host "- Pour fermer l'application, appuyez sur Ctrl+C dans cette fenêtre" -ForegroundColor White
Write-Host "- L'application s'ouvrira automatiquement dans votre navigateur" -ForegroundColor White
Write-Host ""

# Attendre 3 secondes puis ouvrir le navigateur
Write-Host "Ouverture du navigateur dans 3 secondes..." -ForegroundColor Yellow
Start-Sleep -Seconds 3
Start-Process "http://localhost:8080"

Write-Host "Serveur en cours d'exécution..." -ForegroundColor Green
Write-Host "Appuyez sur Ctrl+C pour arrêter le serveur" -ForegroundColor Yellow
Write-Host ""

# Lancer le serveur Python
try {
    python -m http.server 8080
} catch {
    Write-Host "Erreur lors du démarrage du serveur." -ForegroundColor Red
    Read-Host "Appuyez sur Entrée pour quitter"
}
