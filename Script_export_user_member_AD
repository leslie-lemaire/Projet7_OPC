<#
Auteur : Leslie Lemaire
Date : 22/07/2024
Version : 1.0
Révisions :
Description : Script permettant d’afficher/d’exporter la liste des membres d’un groupe AD
#>
<#
Auteur : Leslie Lemaire
Date : 18/07/2024
Version : 1.0
Révisions :
Description : Script permettant d’afficher et d’exporter la liste des membres d’un groupe AD
#>

# Charger le module Active Directory
Import-Module ActiveDirectory

# Fonction pour obtenir les informations du groupe
function Get-GroupInfo {
    $groupName = Read-Host "Nom du groupe AD"
    $exportPath = Read-Host "Chemin complet du fichier d'exportation (par exemple: 'C:\Exports\GroupMembers.csv')"
    return @{
        GroupName = $groupName
        ExportPath = $exportPath
    }
}

# Fonction pour obtenir et afficher les membres du groupe
function Get-GroupMembers {
    param (
        [Parameter(Mandatory=$true)] $groupInfo
    )
    try {
        # Obtenir les membres du groupe
        $members = Get-ADGroupMember -Identity $groupInfo.GroupName | Select-Object Name, SamAccountName, objectClass

        # Vérifier s'il y a des membres dans le groupe
        if ($members.Count -eq 0) {
            Write-Host "Le groupe '$($groupInfo.GroupName)' n'a aucun membre."
        } else {
            # Afficher les membres du groupe
            Write-Host "Liste des membres du groupe '$($groupInfo.GroupName)' :"
            $members | Format-Table -AutoSize

            # Exporter la liste des membres dans un fichier CSV
            $members | Export-Csv -Path $groupInfo.ExportPath -NoTypeInformation
            Write-Host "La liste des membres a été exportée vers '$($groupInfo.ExportPath)'."
        }
    } catch {
        Write-Host "Erreur lors de l'obtention des membres du groupe : $_"
        exit 1
    }
}

# Demander les informations du groupe
$groupInfo = Get-GroupInfo

# Obtenir et afficher les membres du groupe
Get-GroupMembers -groupInfo $groupInfo
