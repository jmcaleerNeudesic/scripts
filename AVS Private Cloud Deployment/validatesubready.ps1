..\avspcdeploy-variables.ps1


Write-Host -ForegroundColor Yellow  "
Validating Subscription Readiness ..." 

$quota = Test-AzVMWareLocationQuotaAvailability -Location $regionfordeployment

if ("Enabled" -eq $quota.Enabled)
{

Write-Host -ForegroundColor Green "
Success: Quota is Enabled on Subscription
"    

Register-AzResourceProvider -ProviderNamespace Microsoft.AVS

Write-Host -ForegroundColor Green "
Success: Resource Provider Enabled
"    

Start-Sleep 5
}


Else

{
Write-Host -ForegroundColor Red "
Subscription $sub Does NOT Have Quota for Azure VMware Solution, please visit the following site for guidance on how to get this service enabled for your subscription.

https://docs.microsoft.com/en-us/azure/azure-vmware/enable-azure-vmware-solution"

Exit

}