$regionfordeployment = "eastus2"
$RGNewOrExisting = "Existing"
$sub = "a43ab6fc-dd26-4a56-a527-b073659b69da"
$ExrGatewayForAVS = "ExRGW-VirtualWorkloads-APAC-Hub"
$pcname = "AVS2-VirtualWorkloads-APAC-AzureCloud"
$rgfordeployment = "VirtualWorkloads-APAC-AzureCloud"
$addressblock = "10.1.0.0/22"
$skus = "AV36"
$numberofhosts = "3"
$internet = "Enabled"
$ExRGWResourceGroup = "VirtualWorkloads-APAC-Hub"
$ExrForAVSRegion = "East US 2"
$ExrGWforAVSResourceGroup = "VirtualWorkloads-APAC-Hub"
$OnPremExRCircuitSub = "3988f2d0-8066-42fa-84f2-5d72f80901da"
$NameOfOnPremExRCircuit = "prod_express_route"
$RGofOnPremExRCircuit = "Prod_AVS_RG"

Select-AzSubscription -SubscriptionId $sub
$privatecloudinfo = Get-AzVMWarePrivateCloud -ResourceGroupName $rgfordeployment -Name $pcname
$avsvcenter = $privatecloudinfo.EndpointVcsa
ping $avsvcenter
$test = Invoke-WebRequest https://www.nova.edu
write-host $test
$test.StatusCode
