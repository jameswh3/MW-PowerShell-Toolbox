
Get-Module -Name Microsoft.Online.SharePoint.PowerShell -ListAvailable
import-module -name microsoft.online.sharepoint.powershell -UseWindowsPowerShell

Connect-SPOService -Url "https://<your tenant>-admin.sharepoint.com"

Start-SPOCopilotAgentInsightsReport -ReportPeriodInDays 28

