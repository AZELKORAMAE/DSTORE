# Script pour créer un raccourci desktop pour MATA24
Write-Host "Création du raccourci desktop pour MATA24..." -ForegroundColor Green

# Chemins
$currentDir = (Get-Location).Path
$vbsPath = Join-Path $currentDir "MATA24_Desktop.vbs"
$iconPath = Join-Path $currentDir "web\icons\Icon-512.png"
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktopPath "MATA24.lnk"

# Vérifier que les fichiers existent
if (-not (Test-Path $vbsPath)) {
    Write-Host "ERREUR: Fichier MATA24_Desktop.vbs non trouvé" -ForegroundColor Red
    exit 1
}

# Créer le raccourci
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = "wscript.exe"
$Shortcut.Arguments = "`"$vbsPath`""
$Shortcut.WorkingDirectory = $currentDir
$Shortcut.Description = "MATA24 - Application de Gestion"
$Shortcut.WindowStyle = 1

# Essayer d'utiliser l'icône PNG (Windows 10/11 supporte les PNG)
if (Test-Path $iconPath) {
    $Shortcut.IconLocation = $iconPath
} else {
    # Utiliser l'icône par défaut de Windows
    $Shortcut.IconLocation = "shell32.dll,21"
}

$Shortcut.Save()

Write-Host "Raccourci créé avec succès sur le bureau !" -ForegroundColor Green
Write-Host "Nom du raccourci: MATA24.lnk" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pour lancer l'application:" -ForegroundColor Yellow
Write-Host "1. Double-cliquez sur l'icône MATA24 sur le bureau" -ForegroundColor White
Write-Host "2. L'application s'ouvrira comme une vraie app desktop" -ForegroundColor White
Write-Host ""
Write-Host "Note: Gardez ce dossier mata24 à cet emplacement" -ForegroundColor Yellow

# Créer aussi un raccourci dans le menu Démarrer
$startMenuPath = [Environment]::GetFolderPath("StartMenu")
$programsPath = Join-Path $startMenuPath "Programs"
$startMenuShortcut = Join-Path $programsPath "MATA24.lnk"

$StartShortcut = $WshShell.CreateShortcut($startMenuShortcut)
$StartShortcut.TargetPath = "wscript.exe"
$StartShortcut.Arguments = "`"$vbsPath`""
$StartShortcut.WorkingDirectory = $currentDir
$StartShortcut.Description = "MATA24 - Application de Gestion"
$StartShortcut.WindowStyle = 1

if (Test-Path $iconPath) {
    $StartShortcut.IconLocation = $iconPath
} else {
    $StartShortcut.IconLocation = "shell32.dll,21"
}

$StartShortcut.Save()

Write-Host "Raccourci ajouté au menu Démarrer !" -ForegroundColor Green
