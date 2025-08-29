import-module -name microsoft.online.sharepoint.powershell -UseWindowsPowerShell

Connect-SPOService -Url $spoAdminUrl

Start-SPOCopilotAgentInsightsReport -ReportPeriodInDays 28

