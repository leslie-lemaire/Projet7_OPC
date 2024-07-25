<#
Auteur : Leslie Lemaire
Date : 25/07/2024
Version : 1.0
Révisions :
Description : Script de création utilisateur AD avec interface graphique pour la sélection de l'OU
#>

# Charger le module Active Directory
Import-Module ActiveDirectory

# Charger le module Windows Forms
Add-Type -AssemblyName System.Windows.Forms

# Fonction pour demander les informations de l'utilisateur
function Get-UserInfo {
    $user = @{}
    
    # Créer la fenêtre principale
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Création d'utilisateur AD"
    $form.Size = New-Object System.Drawing.Size(400,400)
    $form.StartPosition = "CenterScreen"
    
    # Ajouter les champs de saisie pour les informations utilisateur
    $labels = @("Prénom", "Nom", "Nom d'utilisateur (login)", "Mot de passe", "Lettre de lecteur (par exemple: 'H:')", "Nom du groupe de sécurité")
    $textBoxes = @()
    
    for ($i=0; $i -lt $labels.Count; $i++) {
        $label = New-Object System.Windows.Forms.Label
        $label.Text = $labels[$i]
        $label.Location = New-Object System.Drawing.Point(10, 20 + 30 * $i)
        $form.Controls.Add($label)
        
        $textBox = New-Object System.Windows.Forms.TextBox
        $textBox.Location = New-Object System.Drawing.Point(200, 20 + 30 * $i)
        $form.Controls.Add($textBox)
        $textBoxes += $textBox
    }
    
    # Ajouter un champ pour le mot de passe
    $passwordTextBox = New-Object System.Windows.Forms.TextBox
    $passwordTextBox.Location = New-Object System.Drawing.Point(200, 140)
    $passwordTextBox.PasswordChar = '*'
    $form.Controls.Add($passwordTextBox)
    $textBoxes[3] = $passwordTextBox
    
    # Ajouter une liste déroulante pour la sélection de l'OU
    $ouLabel = New-Object System.Windows.Forms.Label
    $ouLabel.Text = "Chemin de l'OU"
    $ouLabel.Location = New-Object System.Drawing.Point(10, 200)
    $form.Controls.Add($ouLabel)
    
    $ouComboBox = New-Object System.Windows.Forms.ComboBox
    $ouComboBox.Location = New-Object System.Drawing.Point(200, 200)
    $ous = Get-ADOrganizationalUnit -Filter * | Select-Object -ExpandProperty DistinguishedName
    $ouComboBox.Items.AddRange($ous)
    $form.Controls.Add($ouComboBox)
    
    # Ajouter un bouton de validation
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "OK"
    $okButton.Location = New-Object System.Drawing.Point(150, 250)
    $okButton.Add_Click({
        $user.FirstName = $textBoxes[0].Text
        $user.LastName = $textBoxes[1].Text
        $user.Username = $textBoxes[2].Text
        $user.Password = $textBoxes[3].Text
        $user.HomeDrive = $textBoxes[4].Text
        $user.SecurityGroup = $textBoxes[5].Text
        $user.OU = $ouComboBox.SelectedItem
        $form.Close()
    })
    $form.Controls.Add($okButton)
    
    # Afficher la fenêtre
    $form.ShowDialog() | Out-Null
    
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
                   -AccountPassword (ConvertTo-SecureString $user.Password -AsPlainText -Force) `
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
