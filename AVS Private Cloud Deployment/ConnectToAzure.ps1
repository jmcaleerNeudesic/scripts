$regionfordeployment = "southeastasia"
$RGNewOrExisting = "Existing"
$sub = "1178f22f-6ce4-45e3-bd92-ba89930be5be"
$ExrGatewayForAVS = "ExRGW-VirtualWorkloads-APAC-Hub"
$pcname = "AVS1-VirtualWorkloads-APAC-AzureCloud"
$rgfordeployment = "VirtualWorkloads-APAC-AzureCloud"
$addressblock = "10.1.0.0/22"
$skus = "AV36"
$numberofhosts = "3"
$internet = "Enabled"

#$deployvariablesvariables = Invoke-WebRequest https://raw.githubusercontent.com/Trevor-Davis/scripts/main/AVS%20Private%20Cloud%20Deployment/avspcdeploy-variables.ps1
#Invoke-Expression $($deployvariablesvariables.Content)

write-host -ForegroundColor Yellow "
Connecting to your Azure Subscription $sub ... there should be a web browser pop-up ... go there to login"
$command = Connect-AzAccount -Subscription $sub
$command | ConvertTo-Json
write-host -ForegroundColor Green "
Azure Login Successful
"
