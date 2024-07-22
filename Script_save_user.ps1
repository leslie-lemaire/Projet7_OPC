<#
Auteur : Leslie Lemaire
Date : 22/07/2024
Version : 1.1
Révisions :
Description : Script pour sauvegarder les dossiers C:\Users des utilisateurs AD vers E:\Sauvegarde sur le serveur, en excluant le serveur local.
#>

# Charger le module Active Directory
Import-Module ActiveDirectory

# Définir le chemin de destination sur le serveur
$serverBackupPath = "E:\Sauvegarde"

# Nom de l'ordinateur local à exclure de la sauvegarde
$localComputerName = "WIN-90LDUDNTQDE"

# Fonction pour obtenir la liste des utilisateurs du domaine
function Get-UserList {
    # Obtenir les utilisateurs avec leurs noms
    $users = Get-ADUser -Filter * | Select-Object -ExpandProperty SamAccountName
    return $users
}

# Fonction pour sauvegarder les données du dossier C:\Users d'un utilisateur depuis un ordinateur vers le serveur
function Backup-UserData {
    param (
        [Parameter(Mandatory=$true)] [string]$userName,
        [Parameter(Mandatory=$true)] [string]$destinationPath
    )

    # Nom de l'ordinateur à adapter (ici on suppose que le nom de l'ordinateur est le même que le nom d'utilisateur, ajustez si nécessaire)
    $computerName = $userName  # Remplacez ceci par la logique appropriée pour obtenir le nom d'ordinateur si nécessaire

    # Vérifier si le nom de l'ordinateur est celui du serveur local
    if ($computerName -eq $localComputerName) {
        Write-Host "Exclusion du serveur local $localComputerName."
        return
    }

    # Chemin source et destination
    $sourcePath = "\\$computerName\C$\Users\$userName"
    $backupPath = Join-Path -Path $destinationPath -ChildPath $userName

    try {
        # Créer le répertoire de sauvegarde s'il n'existe pas
        if (-Not (Test-Path -Path $backupPath)) {
            New-Item -Path $backupPath -ItemType Directory -Force
        }

        # Copier les données du dossier utilisateur vers le serveur
        if (Test-Path -Path $sourcePath) {
            Copy-Item -Path $sourcePath -Destination $backupPath -Recurse -Force
            Write-Host "Les fichiers pour $userName ont été sauvegardés avec succès depuis $computerName."
        } else {
            Write-Host "Le chemin source $sourcePath n'existe pas."
        }
    }
    catch {
        Write-Host "Erreur dans la sauvegarde pour $userName depuis $computerName : $_"
    }
}

# Fonction pour sauvegarder les données de tous les utilisateurs
function Backup-AllUserData {
    param (
        [Parameter(Mandatory=$true)] [string]$serverBackupPath
    )

    # Obtenir la liste des utilisateurs
    $users = Get-UserList

    foreach ($user in $users) {
        Backup-UserData -userName $user -destinationPath $serverBackupPath
    }
}

# Appeler la fonction de sauvegarde
Backup-AllUserData -serverBackupPath $serverBackupPath

Write-Host "La sauvegarde des données est terminée pour tous les utilisateurs."
