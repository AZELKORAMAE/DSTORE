@echo off
echo ========================================
echo    LANCEMENT DE L'APP SUR TELEPHONE
echo ========================================
echo.

echo 1. Verification des appareils connectes...
flutter devices

echo.
echo 2. Nettoyage du cache...
flutter clean

echo.
echo 3. Recuperation des dependances...
flutter pub get

echo.
echo 4. Verification de la configuration...
flutter doctor

echo.
echo 5. Lancement de l'application en mode debug...
echo    (Assurez-vous que votre telephone est connecte en USB)
echo    (Et que le debogage USB est active)
echo.

flutter run --debug

echo.
echo ========================================
echo    LANCEMENT TERMINE
echo ========================================
pause
