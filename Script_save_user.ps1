<#
Auteur : Leslie Lemaire
Date : 24/07/2024
Version : 1.1
Révisions :
- Modifié pour sauvegarder dans un dossier nommé d'après la machine exécutant le script.
Description : Script de sauvegarde des données utilisateurs (C:\Users de chaque PC) dans le serveur (E:\Sauvegardes)
#>

Write-Host "Script de sauvegarde des données utilisateurs des Postes Clients 'C:\Users' sur le Serveur 'WIN-90LDUDNTQDE' dans 'E:\Sauvegardes' * DÉMARRÉ *" -ForegroundColor Yellow -BackgroundColor Black

# Nom de la machine exécutant le script
$machineName = $env:COMPUTERNAME

# Chemin de destination sur le serveur avec un sous-dossier nommé d'après la machine
$destinationPath = "\\WIN-90LDUDNTQDE\Sauvegardes\$machineName"

# Création du dossier de destination si il n'existe pas déjà
if (-not (Test-Path $destinationPath)) {
    New-Item -Path $destinationPath -ItemType Directory | Out-Null
}

# Action de copie des données utilisateurs "C:\Users" des Postes Clients sur le Serveur "WIN-90LDUDNTQDE" dans le répertoire spécifié
Try {
    Copy-Item -Path "C:\Users\*" -Destination $destinationPath -Force -Recurse -Verbose
    Write-Host "* La sauvegarde des données utilisateurs 'C:\Users' a été effectuée dans '$destinationPath' * TERMINÉ *" -ForegroundColor Green -BackgroundColor Black
}

# Message d'avertissement en cas d'erreur dans la copie des données avec un code couleur spécifique
Catch {
    Write-Host "Attention, erreur détectée ! Contrôlez la sauvegarde de vos données utilisateurs !" -ForegroundColor Red -BackgroundColor Black
}

