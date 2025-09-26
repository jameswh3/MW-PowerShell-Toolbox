#Requires -Modules ExchangeOnlineManagement

# Function to check the status of the compliance search
function Get-ComplianceSearchStatus {
    param (
        [string]$searchName
    )
    # Get the status of the compliance search
    $searchStatus = Get-ComplianceSearch -Identity $searchName
    # Return the status
    return $searchStatus.Status
}

# Function to check the status of the compliance search action
function Get-ComplianceSearchActionStatus {
    param (
        [string]$searchActionName
    )
    # Get the status of the compliance search action
    $searchActionStatus = Get-ComplianceSearchAction -Identity $searchActionName
    # Return the status
    return $searchActionStatus.Status
}

#Connect to Compliance Session
Connect-IPPSSession -UserPrincipalName $upn

New-ComplianceSearch -Name $complianceSearchName `
    -ContentMatchQuery $kql `
    -ExchangeLocation $mailbox

Start-ComplianceSearch -Identity $complianceSearchName

# Loop to check the status until the search is completed
do {
    $status = Get-ComplianceSearchStatus -searchName $complianceSearchName
    Write-Host "Current status of the compliance search '$complianceSearchName': $status"
    Start-Sleep -Seconds 10
} while ($status -ne "Completed")

Write-Host "The compliance search '$complianceSearchName' is completed."

$complianceSearchActionName="$complianceSearchName - Export"
New-ComplianceSearchAction -SearchName $complianceSearchName `
    -ActionName $complianceSearchActionName `
    -Export `
    -Format Mime `
    -Confirm

# Loop to check the status until the search action is completed
do {
    $status = Get-ComplianceSearchActionStatus -searchActionName $complianceSearchActionName
    Write-Host "Current status of the compliance search action '$complianceSearchActionName': $status"
    Start-Sleep -Seconds 10
} while ($status -ne "Completed")

Write-Host "The compliance search action '$complianceSearchActionName' is completed."
