<#
Auteur : Leslie Lemaire
Date : 18/07/2024
Version : 1.0
Révisions :
Description : Script de création utilisateur AD et du dossier partagé personnel à l'user
#>

# Charger le module Active Directory
Import-Module ActiveDirectory

# Fonction pour demander les informations de l'utilisateur
function Get-UserInfo {
    $user = @{}
    $user.FirstName = Read-Host "Prénom de l'utilisateur"
    $user.LastName = Read-Host "Nom de l'utilisateur"
    $user.Username = Read-Host "Nom d'utilisateur (login)"
    $user.Password = Read-Host -AsSecureString "Mot de passe"
    $user.OU = Read-Host "OU (par exemple: 'OU=Users,DC=domain,DC=com')"
    $user.HomeDirectory = Read-Host "\\\WIN-90LDUDNTQDE\Partages personnels utilisateurs\$user.FirstName.$user.LastName"
    return $user
}

# Fonction pour créer l'utilisateur AD
function Create-ADUser {
    param (
        [Parameter(Mandatory=$true)] $user
    )
    New-ADUser -Name "$($user.FirstName) $($user.LastName)" `
               -GivenName $user.FirstName `
               -Surname $user.LastName `
               -SamAccountName $user.Username `
               -UserPrincipalName "$($user.Username)@axeplane.loc" `
               -Path $user.OU `
               -AccountPassword $user.Password `
               -Enabled $true `
               -HomeDirectory $user.HomeDirectory `
               -HomeDrive "H:" `
               -PassThru
}

# Fonction pour configurer le dossier partagé personnel
function Configure-HomeDirectory {
    param (
        [Parameter(Mandatory=$true)] $user
    )
    $path = $user.HomeDirectory
    $username = $user.Username
    New-Item -Path $path -ItemType Directory -Force

    # Configurer les permissions
    $acl = Get-Acl $path
    $acl.SetAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$username", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")))
    Set-Acl $path $acl

    # Partager le dossier
    New-SmbShare -Name $username -Path $path -FullAccess "$username"
}

# Demander les informations de l'utilisateur
$userInfo = Get-UserInfo

# Créer l'utilisateur AD
$user = Create-ADUser -user $userInfo

# Configurer le dossier partagé personnel
Configure-HomeDirectory -user $userInfo

Write-Host "Utilisateur et dossier personnel créés avec succès."