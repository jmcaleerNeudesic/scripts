..\avspcdeploy-variables.ps1

write-host -ForegroundColor Yellow "
Connecting to your Azure Subscription $sub ... there should be a web browser pop-up ... go there to login"
$command = Connect-AzAccount -Subscription $sub
$command | ConvertTo-Json
write-host -ForegroundColor Green "
Azure Login Successful
"
