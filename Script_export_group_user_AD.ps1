<#
Auteur : Leslie Lemaire
Date : 18/07/2024
Version : 1.0
Révisions :
Description : Script permettant d’afficher et d’exporter la liste des groupes AD d’un utilisateur
#>

# Charger le module Active Directory
Import-Module ActiveDirectory

# Fonction pour obtenir les informations de l'utilisateur
function Get-UserInfo {
    $username = Read-Host "Nom d'utilisateur AD (par exemple: 'jdoe')"
    $exportPath = Read-Host "Chemin complet du fichier d'exportation (par exemple: 'C:\Exports\UserGroups.csv')"
    return @{
        Username = $username
        ExportPath = $exportPath
    }
}

# Fonction pour obtenir et afficher les groupes de l'utilisateur
function Get-UserGroups {
    param (
        [Parameter(Mandatory=$true)] $userInfo
    )
    try {
        # Obtenir les groupes de l'utilisateur
        $groups = Get-ADUser -Identity $userInfo.Username -Properties MemberOf | 
                  Select-Object -ExpandProperty MemberOf | 
                  ForEach-Object { 
                      $group = Get-ADGroup -Identity $_
                      [PSCustomObject]@{
                          GroupName = $group.Name
                          DistinguishedName = $group.DistinguishedName
                      }
                  }

        # Vérifier s'il y a des groupes
        if ($groups.Count -eq 0) {
            Write-Host "L'utilisateur '$($userInfo.Username)' n'appartient à aucun groupe."
        } else {
            # Afficher les groupes de l'utilisateur
            Write-Host "Liste des groupes auxquels l'utilisateur '$($userInfo.Username)' appartient :"
            $groups | Format-Table -AutoSize

            # Exporter la liste des groupes dans un fichier CSV
            $groups | Export-Csv -Path $userInfo.ExportPath -NoTypeInformation
            Write-Host "La liste des groupes a été exportée vers '$($userInfo.ExportPath)'."
        }
    } catch {
        Write-Host "Erreur lors de l'obtention des groupes de l'utilisateur : $_"
        exit 1
    }
}

# Demander les informations de l'utilisateur
$userInfo = Get-UserInfo

# Obtenir et afficher les groupes de l'utilisateur
Get-UserGroups -userInfo $userInfo
