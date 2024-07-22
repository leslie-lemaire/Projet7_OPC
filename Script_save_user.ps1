<#
Auteur : Leslie Lemaire
Date : 22/07/2024
Version : 1.0
Révisions :
Description : Script de sauvegarde des données utilisateurs (C:\Users de chaque PC) vers un serveur (\\WIN-90LDUDNTQDE\Partages personnels utilisateurs)
#>

# Fonction pour sauvegarder les données utilisateurs
function Backup-UserData {
    param (
        [Parameter(Mandatory=$true)] [string]$sourcePath,
        [Parameter(Mandatory=$true)] [string]$destinationPath
    )

    # Création du chemin de sauvegarde pour l'utilisateur
    $username = $env:USERNAME
    $backupPath = Join-Path -Path $destinationPath -ChildPath $username

    try {
        # Copier les données du dossier utilisateur vers le serveur
        Copy-Item -Path $sourcePath -Destination $backupPath -Recurse -Force
        Write-Host "Les fichiers ont été sauvegardés avec succès pour l'utilisateur $username."
    }
    catch {
        Write-Host "Erreur dans la sauvegarde pour l'utilisateur $username : $_"
    }
}

# Définir les chemins source et destination
$dossierASauvegarder = "C:\Users\$env:USERNAME"
$destination = "\\WIN-90LDUDNTQDE\Partages personnels utilisateurs"

# Appeler la fonction de sauvegarde
Backup-UserData -sourcePath $dossierASauvegarder -destinationPath $destination
