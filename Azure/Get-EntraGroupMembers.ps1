[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$GroupNameOrEmail
)


# Connect to Microsoft Graph if not already connected
try {
    $context = Get-MgContext
    if (-not $context -or $context.Scopes -notcontains "Group.Read.All") {
        Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Yellow
        Connect-MgGraph -Scopes "Group.Read.All", "User.Read.All" -NoWelcome
        Write-Host "Successfully connected to Microsoft Graph" -ForegroundColor Green
    } else {
        Write-Host "Already connected to Microsoft Graph" -ForegroundColor Green
    }
}
catch {
    Write-Error "Failed to connect to Microsoft Graph: $($_.Exception.Message)"
    exit 1
}

# Get the group by name or email
try {
    Write-Host "Searching for group: '$GroupNameOrEmail'..." -ForegroundColor Yellow
    
    # Try exact match first on display name
    $group = Get-MgGroup -Filter "displayName eq '$GroupNameOrEmail'" -ErrorAction SilentlyContinue
    
    # If not found, try email
    if (-not $group) {
        $group = Get-MgGroup -Filter "mail eq '$GroupNameOrEmail'" -ErrorAction SilentlyContinue
    }
    
    # If still not found, try contains search on display name
    if (-not $group) {
        $group = Get-MgGroup -Filter "startswith(displayName,'$GroupNameOrEmail')" -ErrorAction SilentlyContinue
    }
    
    if (-not $group) {
        Write-Host "Group '$GroupNameOrEmail' not found. Searching for similar groups..." -ForegroundColor Yellow
        $similarGroups = Get-MgGroup -Filter "contains(displayName,'$GroupNameOrEmail')" -Top 5 -ErrorAction SilentlyContinue
        if ($similarGroups) {
            Write-Host "Did you mean one of these groups?" -ForegroundColor Cyan
            foreach ($sg in $similarGroups) {
                Write-Host "  - $($sg.DisplayName) ($($sg.Mail))" -ForegroundColor Cyan
            }
        }
        Write-Error "Group '$GroupNameOrEmail' not found"
        exit 1
    }
    
    Write-Host "Found group: $($group.DisplayName)" -ForegroundColor Green
}
catch {
    Write-Error "Failed to get group: $($_.Exception.Message)"
    exit 1
}

# Get group members
try {
    Write-Host "Getting members of group '$($group.DisplayName)'..." -ForegroundColor Yellow
    $members = Get-MgGroupMember -GroupId $group.Id -All
    
    if ($members) {
        Write-Host "`nMembers of group '$($group.DisplayName)' ($($members.Count) total):" -ForegroundColor Green
        
        $userCount = 0
        $serviceprincipals = 0
        $groups = 0
        
        foreach ($member in $members) {
            # Handle different member types
            switch ($member.AdditionalProperties.'@odata.type') {
                '#microsoft.graph.user' {
                    $userDetails = Get-MgUser -UserId $member.Id -ErrorAction SilentlyContinue
                    if ($userDetails) {
                        Write-Host "👤 User: $($userDetails.DisplayName) ($($userDetails.UserPrincipalName))" -ForegroundColor White
                        $userCount++
                    }
                }
                '#microsoft.graph.group' {
                    $groupDetails = Get-MgGroup -GroupId $member.Id -ErrorAction SilentlyContinue
                    if ($groupDetails) {
                        Write-Host "👥 Group: $($groupDetails.DisplayName)" -ForegroundColor Cyan
                        $groups++
                    }
                }
                '#microsoft.graph.servicePrincipal' {
                    $spDetails = Get-MgServicePrincipal -ServicePrincipalId $member.Id -ErrorAction SilentlyContinue
                    if ($spDetails) {
                        Write-Host "🔧 Service Principal: $($spDetails.DisplayName)" -ForegroundColor Magenta
                        $serviceprincipals++
                    }
                }
                default {
                    Write-Host "❓ Unknown member type: $($member.Id)" -ForegroundColor Yellow
                }
            }
        }
        
        Write-Host "`nSummary:" -ForegroundColor Green
        Write-Host "  Users: $userCount" -ForegroundColor White
        Write-Host "  Groups: $groups" -ForegroundColor Cyan
        Write-Host "  Service Principals: $serviceprincipals" -ForegroundColor Magenta
        Write-Host "  Total: $($members.Count)" -ForegroundColor Green
    }
    else {
        Write-Host "No members found in group '$($group.DisplayName)'" -ForegroundColor Yellow
    }
}
catch {
    Write-Error "Failed to get group members: $($_.Exception.Message)"
    exit 1
}