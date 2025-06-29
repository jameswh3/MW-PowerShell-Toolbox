param(
    [Parameter(Mandatory = $true)]
    [string]$TeamId,

    [Parameter(Mandatory = $true)]
    [string[]]$ChannelNames
)

# Ensure MicrosoftTeams module is installed and imported
if (-not (Get-Module -ListAvailable -Name MicrosoftTeams)) {
    Install-Module -Name MicrosoftTeams -Force -Scope CurrentUser
}
Import-Module MicrosoftTeams


foreach ($channel in $ChannelNames) {
    try {
        Write-Host "Creating channel '$channel' in Team ID '$TeamId'..."
        New-TeamChannel -GroupId $TeamId -DisplayName $channel -ErrorAction Stop
        Write-Host "Channel '$channel' created successfully."
    }
    catch {
        Write-Warning "Failed to create channel '$channel': $_"
    }
}