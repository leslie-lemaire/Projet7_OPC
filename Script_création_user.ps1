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
    $user.OU = (Get-ADOrganizationalUnit -Filter * | Out-GridView -Title "Choisissez une OU pour cet utilisateur" -PassThru).DistinguishedName
    $user.HomeDrive = Read-Host "Lettre de lecteur pour le dossier personnel (par exemple: 'H:')"
    $user.SecurityGroup = Read-Host "Nom du groupe de sécurité (par exemple: 'GroupeSécurité')"
    return $user
}

# Fonction pour créer l'utilisateur AD
function Create-ADUser {
    param (
        [Parameter(Mandatory=$true)] $user
    )
    try {
        # Définir le chemin du dossier personnel basé sur le login choisi
        $homeDirectory = "\\WIN-90LDUDNTQDE\Partages personnels utilisateurs\$($user.Username)"

        New-ADUser -Name "$($user.FirstName) $($user.LastName)" `
                   -GivenName $user.FirstName `
                   -Surname $user.LastName `
                   -SamAccountName $user.Username `
                   -UserPrincipalName "$($user.Username)@axeplane.loc" `
                   -Path $user.OU `
                   -AccountPassword $user.Password `
                   -Enabled $true `
                   -HomeDirectory $homeDirectory `
                   -HomeDrive $user.HomeDrive `
                   -PassThru
    } catch {
        Write-Host "Erreur lors de la création de l'utilisateur : $_"
        exit 1
    }
}

# Fonction pour configurer le dossier partagé personnel
function Configure-HomeDirectory {
    param (
        [Parameter(Mandatory=$true)] $user
    )
    $path = "\\WIN-90LDUDNTQDE\Partages personnels utilisateurs\$($user.Username)"
    $username = $user.Username
    
    try {
        # Créer le dossier s'il n'existe pas
        if (-Not (Test-Path -Path $path)) {
            New-Item -Path $path -ItemType Directory -Force
        }

        # Configurer les permissions
        $acl = Get-Acl $path
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$username", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
        $acl.SetAccessRule($accessRule)
        Set-Acl $path $acl

    } catch {
        Write-Host "Erreur lors de la configuration du dossier partagé : $_"
        exit 1
    }
}

# Fonction pour ajouter l'utilisateur au groupe de sécurité
function Add-UserToSecurityGroup {
    param (
        [Parameter(Mandatory=$true)] $user
    )
    try {
        Add-ADGroupMember -Identity $user.SecurityGroup -Members $user.Username
    } catch {
        Write-Host "Erreur lors de l'ajout de l'utilisateur au groupe de sécurité : $_"
        exit 1
    }
}

# Demander les informations de l'utilisateur
$userInfo = Get-UserInfo

# Créer l'utilisateur AD
$user = Create-ADUser -user $userInfo

# Configurer le dossier partagé personnel
Configure-HomeDirectory -user $userInfo

# Ajouter l'utilisateur au groupe de sécurité
Add-UserToSecurityGroup -user $userInfo

Write-Host "Utilisateur et dossier personnel créés avec succès."