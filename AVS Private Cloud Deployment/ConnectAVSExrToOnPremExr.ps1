$deployvariablesvariables = Invoke-WebRequest https://raw.githubusercontent.com/Trevor-Davis/scripts/main/AVS%20Private%20Cloud%20Deployment/avspcdeploy-variables.ps1
Invoke-Expression $($deployvariablesvariables.Content)

Select-AzSubscription -SubscriptionId $sub
New-AzVMwareGlobalReachConnection -Name $NameOfOnPremExRCircuit -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment -AuthorizationKey "dc9dc896-40b1-46b6-8349-9411833a8abd" -PeerExpressRouteResourceId "/subscriptions/be8569eb-b087-4090-a1e2-ac12df4818d8/resourceGroups/tnt43-cust-p01-southeastasia/providers/Microsoft.Network/expressRouteCircuits/tnt43-cust-p01-southeastasia-er"

$provisioningstate = Get-AzVMwareGlobalReachConnection -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.CircuitConnectionStatus

while ("Connected" -ne $currentprovisioningstate)
{
write-Host -Fore "Current Status of Global Reach Connection: $currentprovisioningstate"
Start-Sleep -Seconds 10
$provisioningstate = Get-AzVMwareGlobalReachConnection -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.CircuitConnectionStatus}

if("Connected" -eq $currentprovisioningstate)
{
  Write-Host -ForegroundColor Green "Success: AVS Private Cloud $pcname is Connected via Global Reach to $NameOfOnPremExRCircuit"
}  



<#
Select-AzSubscription -SubscriptionId $OnPremExRCircuitSub

$OnPremExRCircuit = Get-AzExpressRouteCircuit -Name $NameOfOnPremExRCircuit -ResourceGroupName $RGofOnPremExRCircuit
Add-AzExpressRouteCircuitAuthorization -Name "For-$pcname" -ExpressRouteCircuit $OnPremExRCircuit
Set-AzExpressRouteCircuit -ExpressRouteCircuit $OnPremExRCircuit

Write-Host -ForegroundColor Green "
Success: Auth Key Genereated for AVS On Express Route $NameOfOnPremExRCircuit"

$OnPremExRCircuit = Get-AzExpressRouteCircuit -Name $NameOfOnPremExRCircuit -ResourceGroupName $RGofOnPremExRCircuit
$OnPremCircuitAuthDetails = Get-AzExpressRouteCircuitAuthorization -ExpressRouteCircuit $OnPremExRCircuit | Where-Object {$_.Name -eq "For-$pcname"}
$OnPremCircuitAuth = $OnPremCircuitAuthDetails.AuthorizationKey

Select-AzSubscription -SubscriptionId $sub
New-AzVMwareGlobalReachConnection -Name $NameOfOnPremExRCircuit -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment -AuthorizationKey $OnPremCircuitAuth -PeerExpressRouteResourceId $OnPremExRCircuit.Id

$provisioningstate = Get-AzVMwareGlobalReachConnection -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.CircuitConnectionStatus

while ("Connected" -ne $currentprovisioningstate)
{
write-Host -Fore "Current Status of Global Reach Connection: $currentprovisioningstate"
Start-Sleep -Seconds 10
$provisioningstate = Get-AzVMwareGlobalReachConnection -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.CircuitConnectionStatus}

if("Connected" -eq $currentprovisioningstate)
{
  Write-Host -ForegroundColor Green "Success: AVS Private Cloud $pcname is Connected via Global Reach to $NameOfOnPremExRCircuit"
  
}
#>