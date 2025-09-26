<#
.SYNOPSIS
    Retrieves CS Meeting Policies from Microsoft Teams and identifies assigned users/groups

.DESCRIPTION
    This script connects to Microsoft Teams PowerShell module and retrieves
    all CS Meeting Policies configured in the tenant, along with the users
    and groups that have each policy assigned.

.PARAMETER OutputPath
    Optional path to export results to CSV file

.EXAMPLE
    .\Get-TeamsPolicies.ps1
    Retrieves all CS Meeting Policies with assignments and displays them in the console

.EXAMPLE
    .\Get-TeamsPolicies.ps1 -OutputPath "C:\Reports\TeamsPolicies.csv"
    Retrieves policies with assignments and exports to CSV file

.NOTES
    Requires MicrosoftTeams module
    Author: GitHub Copilot
    Date: $(Get-Date -Format 'yyyy-MM-dd')
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$OutputPath
)

# Import and connect to Microsoft Teams
if (!(Get-Module -Name MicrosoftTeams)) {
    Write-Host "Importing MicrosoftTeams module..." -ForegroundColor Yellow
    Import-Module MicrosoftTeams -ErrorAction Stop
}

# Check if already connected to Microsoft Teams, if not connect
try {
    $teamsConnection = Get-CsTenant -ErrorAction Stop
    Write-Host "Already connected to Microsoft Teams" -ForegroundColor Green
}
catch {
    Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Yellow
    Connect-MicrosoftTeams
}

# Retrieve Teams Meeting Policies
Write-Host "Retrieving Teams Meeting Policies..." -ForegroundColor Yellow
$meetingPolicies = Get-CsTeamsMeetingPolicy

Write-Host "Found $($meetingPolicies.Count) meeting policies" -ForegroundColor Green

# Get all users once to improve performance
Write-Host "Retrieving all users..." -ForegroundColor Yellow
$allUsers = Get-CsOnlineUser

# Get all group policy assignments once
Write-Host "Retrieving group policy assignments..." -ForegroundColor Yellow
$allGroupAssignments = Get-CsGroupPolicyAssignment -PolicyType TeamsMeetingPolicy

# Create array to store policy assignment information
$policyAssignments = @()

foreach ($policy in $meetingPolicies) {
    Write-Host "Processing policy: $($policy.Identity)" -ForegroundColor Cyan
    
    # Filter users assigned to this specific policy
    $assignedUsers = $allUsers | Where-Object { $_.TeamsMeetingPolicy -eq $policy.Identity }
    $userCount = ($assignedUsers | Measure-Object).Count
    
    # Filter group assignments for this specific policy
    $groupAssignments = $allGroupAssignments | Where-Object { $_.PolicyName -eq $policy.Identity }
    $groupCount = ($groupAssignments | Measure-Object).Count
    
    # Create object with policy and assignment details
    $policyInfo = [PSCustomObject]@{
        PolicyIdentity = $policy.Identity
        Description = $policy.Description
        AllowMeetingRecording = $policy.AllowMeetingRecording
        AllowCloudRecording = $policy.AllowCloudRecording
        AllowIPVideo = $policy.AllowIPVideo
        NewMeetingRecordingExpirationDays = $policy.NewMeetingRecordingExpirationDays
        AssignedUsersCount = $userCount
        AssignedGroupsCount = $groupCount
        AssignedUsers = if ($assignedUsers) { ($assignedUsers.UserPrincipalName -join "; ") } else { "" }
        AssignedGroups = if ($groupAssignments) { ($groupAssignments.GroupId -join "; ") } else { "" }
    }
    
    $policyAssignments += $policyInfo
}

# Display policies with assignments in console
Write-Host "`nPolicy Assignment Summary:" -ForegroundColor Green
$policyAssignments | Format-Table PolicyIdentity, AssignedUsersCount, AssignedGroupsCount, Description -AutoSize

# Display detailed view
Write-Host "`nDetailed Policy Information:" -ForegroundColor Green
foreach ($assignment in $policyAssignments) {
    Write-Host "`nPolicy: $($assignment.PolicyIdentity)" -ForegroundColor Yellow
    Write-Host "  Users assigned: $($assignment.AssignedUsersCount)"
    Write-Host "  Groups assigned: $($assignment.AssignedGroupsCount)"
    
    if ($assignment.AssignedUsers) {
        Write-Host "  Assigned Users: $($assignment.AssignedUsers)"
    }
    
    if ($assignment.AssignedGroups) {
        Write-Host "  Assigned Groups: $($assignment.Assignments)"
    }
}

# Export to CSV if OutputPath is provided
if ($OutputPath) {
    $policyAssignments | Export-Csv -Path $OutputPath -NoTypeInformation
    Write-Host "`nPolicies with assignments exported to: $OutputPath" -ForegroundColor Green
}

# Disconnect from Microsoft Teams
Disconnect-MicrosoftTeams