<#
    #Modify the variables below to match your environment and uncomment this section to run the script
    $orgUrl= "https://<your org>.crm.dynamics.com/"
    $role="System Administrator"
    $appId="<your app id>"
#>

pac auth create

pac admin assign-user -u $appId -au -env $orgUrl -r $role
