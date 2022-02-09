$variables = Invoke-WebRequest https://raw.githubusercontent.com/Trevor-Davis/scripts/main/AVS%20Private%20Cloud%20Deployment/avspcdeploy-variables.ps1
Invoke-Expression $($variables.Content)

write-host -ForegroundColor Yellow "
Connecting to your Azure Subscription $sub ... there should be a web browser pop-up ... go there to login"
$command = Connect-AzAccount -Subscription $sub
$command | ConvertTo-Json
write-host -ForegroundColor Green "
Azure Login Successful
"
