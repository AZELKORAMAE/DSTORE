@echo off
echo ========================================
echo        MATA24 - APPLICATION DESKTOP
echo ========================================
echo.
echo Lancement de l'application MATA24...
echo.

REM Vérifier si Python est installé
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERREUR: Python n'est pas installé ou n'est pas dans le PATH.
    echo Veuillez installer Python depuis https://python.org
    pause
    exit /b 1
)

REM Aller dans le dossier build/web
cd /d "%~dp0build\web"

REM Lancer le serveur HTTP local
echo Démarrage du serveur local...
echo L'application sera disponible à l'adresse: http://localhost:8080
echo.
echo IMPORTANT: 
echo - Gardez cette fenêtre ouverte pendant l'utilisation
echo - Pour fermer l'application, fermez cette fenêtre
echo - L'application s'ouvrira automatiquement dans votre navigateur
echo.

REM Attendre 2 secondes puis ouvrir le navigateur
timeout /t 2 /nobreak >nul
start http://localhost:8080

REM Lancer le serveur Python
echo Serveur en cours d'exécution...
python -m http.server 8080
