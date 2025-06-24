
Connect-MgGraph -ClientId $clientId `
    -TenantId $tenantId `
    -NoWelcome


Get-MgReportM365AppUserCount -Period D30 -OutFile c:\temp\report.csv

$result=Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/beta/reports/microsoft.graph.getMicrosoft365CopilotUsageUserDetail(period='D30')"

$result | exportto-json -depth 10