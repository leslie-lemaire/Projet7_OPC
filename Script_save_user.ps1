<#
Auteur : Leslie Lemaire
Date : 22/07/2024
Version : 1.0
Révisions :
Description : Script pour sauvegarder le dossier C:\Users de chaque PC du domaine AD vers E:\Sauvegarde sur le serveur.
#>

# Charger le module Active Directory
Import-Module ActiveDirectory

# Définir le chemin de destination sur le serveur
$serverBackupPath = "E:\Sauvegarde"

# Fonction pour obtenir la liste des ordinateurs du domaine
function Get-ComputerList {
    $computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name
    return $computers
}

# Fonction pour sauvegarder les données des utilisateurs d'un PC vers le serveur
function Backup-UserDataFromComputer {
    param (
        [Parameter(Mandatory=$true)] [string]$computerName,
        [Parameter(Mandatory=$true)] [string]$destinationPath
    )

    $sourcePath = "\\$computerName\C$\Users"
    $backupPath = Join-Path -Path $destinationPath -ChildPath $computerName

    try {
        # Créer le répertoire de sauvegarde s'il n'existe pas
        if (-Not (Test-Path -Path $backupPath)) {
            New-Item -Path $backupPath -ItemType Directory -Force
        }

        # Copier les données du dossier utilisateur vers le serveur
        Copy-Item -Path $sourcePath -Destination $backupPath -Recurse -Force
        Write-Host "Les fichiers ont été sauvegardés avec succès depuis $computerName."
    }
    catch {
        Write-Host "Erreur dans la sauvegarde depuis $computerName : $_"
    }
}

# Fonction pour sauvegarder les données de tous les ordinateurs
function Backup-AllUserData {
    param (
        [Parameter(Mandatory=$true)] [string]$serverBackupPath
    )

    # Obtenir la liste des ordinateurs
    $computers = Get-ComputerList

    foreach ($computer in $computers) {
        Backup-UserDataFromComputer -computerName $computer -destinationPath $serverBackupPath
    }
}

# Appeler la fonction de sauvegarde
Backup-AllUserData -serverBackupPath $serverBackupPath

Write-Host "La sauvegarde des données est terminée pour tous les ordinateurs du domaine."
