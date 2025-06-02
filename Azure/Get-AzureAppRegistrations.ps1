# Connect to Azure
Connect-AzAccount

# Select the appropriate subscription if needed
# Get-AzSubscription | Out-GridView -PassThru | Set-AzContext

# Get all App Registrations (Applications)
$appRegistrations = Get-AzADApplication

# Display Name and AppId
$appRegistrations | Select-Object DisplayName, AppId | Sort-Object DisplayName | Format-Table -AutoSize |