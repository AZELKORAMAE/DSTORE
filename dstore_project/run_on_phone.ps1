# Script PowerShell pour lancer l'app Flutter sur téléphone

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    LANCEMENT DE L'APP SUR TELEPHONE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Vérification des appareils connectés..." -ForegroundColor Yellow
flutter devices

Write-Host ""
Write-Host "2. Nettoyage du cache..." -ForegroundColor Yellow
flutter clean

Write-Host ""
Write-Host "3. Récupération des dépendances..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "4. Vérification de la configuration..." -ForegroundColor Yellow
flutter doctor

Write-Host ""
Write-Host "5. Lancement de l'application en mode debug..." -ForegroundColor Green
Write-Host "   (Assurez-vous que votre téléphone est connecté en USB)" -ForegroundColor Red
Write-Host "   (Et que le débogage USB est activé)" -ForegroundColor Red
Write-Host ""

try {
    flutter run --debug
    Write-Host ""
    Write-Host "Application lancée avec succès !" -ForegroundColor Green
}
catch {
    Write-Host ""
    Write-Host "Erreur lors du lancement : $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Vérifiez que :" -ForegroundColor Yellow
    Write-Host "- Votre téléphone est connecté en USB" -ForegroundColor White
    Write-Host "- Le débogage USB est activé" -ForegroundColor White
    Write-Host "- Les pilotes USB sont installés" -ForegroundColor White
    Write-Host "- Flutter est correctement configuré" -ForegroundColor White
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    SCRIPT TERMINÉ" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Read-Host "Appuyez sur Entrée pour fermer"
