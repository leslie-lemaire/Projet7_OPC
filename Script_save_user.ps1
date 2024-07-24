<#
Auteur : Leslie Lemaire
Date : 24/07/2024
Version : 1.0
Révisions :
Description : Script de sauvegarde des données utilisateurs (C:\Users de chaque PC) dans le serveur (E:\Sauvegardes)
#>

Write-Host "Script de sauvegarde des données utilisateurs des Postes Clients 'C:\Utilisateurs' sur le Serveur 'WIN-90LDUDNTQDE' dans 'E:\Sauvegardes' * DÉMARRÉ *" -ForegroundColor Yellow -BackgroundColor Black



#  Action de copie des données utilisateurs "C:\Utilisateurs" des Postes Clients sur le Serveur "WIN-90LDUDNTQDE" dans le répertoire "E:\Sauvegardes"

Try {

Copy-Item -Path "C:\Users\*" -Destination "\\WIN-90LDUDNTQDE\Sauvegardes" -Force -Recurse -Verbose

Write-Host "* La sauvegarde des données utilisateurs 'C:\Utilisateurs' a été effectuée dans '$path' * TERMINÉ *" -ForegroundColor Green -BackgroundColor Black
}



#  Message d'avertissement en cas d'erreur dans la copie des données avec un code couleur spécifique

Catch {

Write-Host "Attention, erreur détectée ! Contrôlez la sauvegarde de vos données utilisateurs !" -ForegroundColor Red -BackgroundColor Black

}   
