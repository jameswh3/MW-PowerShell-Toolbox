$appId = "<APP_ID>"
$orgUrl = "<ORG_URL>"
$role = "System Administrator"


pac auth create

pac admin assign-user -u $appId -au -env $orgUrl -r $role
