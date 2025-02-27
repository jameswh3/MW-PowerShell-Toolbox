#Requires -Modules Microsoft.Entra

Connect-Entra -Scopes "User.Read.All" -UseDeviceCode

Get-EntraUser -UserId $upn
