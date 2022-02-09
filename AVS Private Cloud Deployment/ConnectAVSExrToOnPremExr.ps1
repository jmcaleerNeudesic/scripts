$regionfordeployment = "southeastasia"
$RGNewOrExisting = "Existing"
$sub = "1178f22f-6ce4-45e3-bd92-ba89930be5be"
$ExrGatewayForAVS = "ExRGW-VirtualWorkloads-APAC-Hub"
$pcname = "AVS2-VirtualWorkloads-APAC-AzureCloud"
$rgfordeployment = "VirtualWorkloads-APAC-AzureCloud"
$addressblock = "10.1.0.0/22"
$skus = "AV36"
$numberofhosts = "3"
$internet = "Enabled"
$ExRGWResourceGroup = "VirtualWorkloads-APAC-Hub"
$ExrForAVSRegion = "Southeast Asia"
$ExrGWforAVSResourceGroup = "VirtualWorkloads-APAC-Hub"
$OnPremExRCircuitSub = "3988f2d0-8066-42fa-84f2-5d72f80901da"
$NameOfOnPremExRCircuit = "prod_express_route"
$RGofOnPremExRCircuit = "Prod_AVS_RG"




#$deployvariablesvariables = Invoke-WebRequest https://raw.githubusercontent.com/Trevor-Davis/scripts/main/AVS%20Private%20Cloud%20Deployment/avspcdeploy-variables.ps1
#Invoke-Expression $($deployvariablesvariables.Content)

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