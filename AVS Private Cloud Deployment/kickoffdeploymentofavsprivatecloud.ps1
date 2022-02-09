$variables = Invoke-WebRequest https://raw.githubusercontent.com/Trevor-Davis/scripts/main/AVS%20Private%20Cloud%20Deployment/avspcdeploy-variables.ps1
Invoke-Expression $($variables.Content)

$deploymentkickofftime = get-date -format "hh:mm"

Write-Host -ForegroundColor Green "
Success: The Azure VMware Solution Private Cloud Deployment Has Begun
"
# New-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment -SubscriptionId $sub -NetworkBlock $addressblock -Sku $skus -Location $regionfordeployment -NsxtPassword $nsxpassword -VcenterPassword $vcenterpassword -managementclustersize $numberofhosts -Internet $internet -NoWait
New-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment -SubscriptionId $sub -NetworkBlock $addressblock -Sku $skus -Location $regionfordeployment -NsxtPassword $nsxpassword -VcenterPassword $vcenterpassword -managementclustersize $numberofhosts -Internet $internet -NoWait -WhatIf

Write-Host -foregroundcolor Magenta "
The Azure VMware Solution Private Cloud $pcname deployment is underway and will take approximately 4 hours, the status of the deployment will update every 5 minutes.

The start time of the deployment was $deploymentkickofftime
"
#Start-Sleep -Seconds 300
Start-Sleep -Seconds 10

$provisioningstate = get-azvmwareprivatecloud -Name $pcname -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.ProvisioningState
$timeStamp = Get-Date -Format "hh:mm"


while ("Succeeded" -ne $currentprovisioningstate)
{
$timeStamp = Get-Date -Format "hh:mm"
"$timestamp - Current Status: $currentprovisioningstate "
#Start-Sleep -Seconds 300
Start-Sleep -Seconds 10
$provisioningstate = get-azvmwareprivatecloud -Name $pcname -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.ProvisioningState
}

if("Succeeded" -eq $currentprovisioningstate)
{
  Write-Host -ForegroundColor Green "$timestamp - Azure VMware Solution Private Cloud $pcname is successfully deployed"
  
}

if("Failed" -eq $currentprovisioningstate)
{
  Write-Host -ForegroundColor Red "$timestamp - Current Status: $currentprovisioningstate

  There appears to be a problem with the deployment of Azure VMware Solution Private Cloud $pcname in subscription $sub "

  Exit

}