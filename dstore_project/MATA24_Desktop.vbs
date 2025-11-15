Set WshShell = CreateObject("WScript.Shell")

' Aller dans le dossier de l'application
WshShell.CurrentDirectory = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)

' Lancer l'application en mode caché (sans fenêtre de commande visible)
WshShell.Run "powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File launch_mata24_desktop.ps1", 0, False

' Attendre 5 secondes pour que le serveur démarre
WScript.Sleep 5000

' Ouvrir le navigateur en mode application (ressemble à une app desktop)
WshShell.Run "chrome --app=http://localhost:8080 --window-size=1200,800 --window-position=100,100", 1, False
