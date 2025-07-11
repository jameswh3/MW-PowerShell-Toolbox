#Requires -Modules Microsoft.Entra

Connect-Entra

Get-EntraUser -UserId $upn
