# Author: Trevor Davis
# Twitter: @vTrevorDavis


# Powershell 7 Is Required

# This script will ask the user to create a new virtual network or use an existing virtual network.  If new, will use the resource group define when creating the private cloud.

########## Read In The Variables  #######################################

#Browsing for user input file ####################
$anykey = Read-Host -Prompt "Browse for the file avsinputs.xlsm on your local system ... press any key to continue"
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
[void]$FileBrowser.ShowDialog()

$file = $FileBrowser.FileName
$sheetName = "userinputs"

#Create an instance of Excel.Application and Open Excel file
$objExcel = New-Object -ComObject Excel.Application
$workbook = $objExcel.Workbooks.Open($file)
$sheet = $workbook.Worksheets.Item($sheetName)
$objExcel.Visible=$false
#Count max row
$rowMax = ($sheet.UsedRange.Rows).count
#Declare the starting positions
$rowsub,$colsub = 1,1
$rowrgnewold,$colrgnewold = 1,2
$rowrgfordeployment,$colrgfordeployment = 1,3
$rowregionfordeployment,$colregionfordeployment = 1,4
$rowpcname,$colpcname = 1,5
$rowvnetandexr,$colvnetandexr = 1,6
$rowvnetname,$colvnetname = 1,7
$rowvnetaddressprefix,$colvnetaddressprefix = 1,8
$rowdefaultsubnetprefix,$coldefaultsubnetprefix = 1,9
$rowgwsubnetprefix,$colgwsubnetprefix = 1,10

#loop to get values and store it ####################
for ($i=1; $i -le $rowMax-1; $i++)
{
$sub = $sheet.Cells.Item($rowsub+$i,$colsub).text
$rgnewold = $sheet.Cells.Item($rowrgnewold+$i,$colrgnewold).text
$rgfordeployment = $sheet.Cells.Item($rowrgfordeployment+$i,$colrgfordeployment).text
$regionfordeployment = $sheet.Cells.Item($rowregionfordeployment+$i,$colregionfordeployment).text
$pcname = $sheet.Cells.Item($rowpcname+$i,$colpcname).text
$vnetandexr = $sheet.Cells.Item($rowvnetandexr+$i,$colvnetandexr).text
$vnetname = $sheet.Cells.Item($rowvnetname+$i,$colvnetname).text
$vnetaddressprefix = $sheet.Cells.Item($rowvnetaddressprefix+$i,$colvnetaddressprefix).text
$defaultsubnetprefix = $sheet.Cells.Item($rowdefaultsubnetprefix+$i,$coldefaultsubnetprefix).text
$gwsubnetprefix = $sheet.Cells.Item($rowgwsubnetprefix+$i,$colgwsubnetprefix).text

<#Write-Host ("Subscription: "+$sub)
Write-Host ("Create New or Use Existing Resource Group: "+$rgnewold)
Write-Host ("Resource Group: "+$rgfordeployment)
Write-Host ("Region: "+$regionfordeployment)
write-Host ("Private Cloud Name:"+$pcname)
write-Host ("vNet and ExR Combo:"+$vnetandexr)
Write-Host ("New vNet Name: "+$vnetname)
Write-Host ("vNet Address Prefix: "+$vnetaddressprefix)
Write-Host ("Default Subnet Prefix: "+$defaultsubnetprefix)
Write-Host ("Gateway Subnet Prefix: "+$gwsubnetprefix)
#>
}
#close excel file ####################
$objExcel.quit()


$gwname = "$pcname-ExRGW"
$gwipName = "$gwname-IP"
$gwipconfName = "$gwname-ipconf"
$gatewaysubnetname = "GatewaySubnet"
$defaultsubnetname = "default"

########## Connect To Azure  #######################################

Clear-Host
write-host "
The script will now connect you to your Azure Subscription $sub ... there should be a web browser pop-up ... go there to login"
Connect-AzAccount -Subscription $sub

########## Option 1 Create a New Azure Virtual Network and ExpressRoute Gateway #################################

if ("1" -eq $vnetandexr) {

  # CREATES THE VNET AND DEFAULT SUBNET  ################################
   
  New-AzVirtualNetwork -ResourceGroupName $rgfordeployment -Location $regionfordeployment -Name $vnetname -AddressPrefix $vnetaddressprefix 
  New-AzVirtualNetworkSubnetConfig -Name $defaultsubnetname -AddressPrefix $defaultsubnetprefix
  $avsvnet = Get-AzVirtualNetwork -Name $vnetname -ResourceGroupName $rgfordeployment
  Add-AzVirtualNetworkSubnetConfig -Name $defaultsubnetname -VirtualNetwork $avsvnet -AddressPrefix $defaultsubnetprefix
  $avsvnet | Set-AzVirtualNetwork
  
  # $avsgatewaysubnetconfig = New-AzVirtualNetworkSubnetConfig -Name $gatewaysubnetname -AddressPrefix $gwsubnetprefix
  # $avsgatewaysubnet = Add-AzVirtualNetworkSubnetConfig -Name $gatewaysubnetname -VirtualNetwork $avsvnet -AddressPrefix $gwsubnetprefix
  
  # CREATES THE GATEWAY SUBNET AND EXR GATEWAY ################################
   
  $vnet = Get-AzVirtualNetwork -Name $vnetname -ResourceGroupName $rgfordeployment
  Add-AzVirtualNetworkSubnetConfig -Name $gatewaysubnetname -VirtualNetwork $vnet -AddressPrefix $gwsubnetprefix
  $vnet = Set-AzVirtualNetwork -VirtualNetwork $vnet
  $subnet = Get-AzVirtualNetworkSubnetConfig -Name $gatewaysubnetname -VirtualNetwork $vnet
  $pip = New-AzPublicIpAddress -Name $gwipName  -ResourceGroupName $rgfordeployment -Location $regionfordeployment -AllocationMethod Dynamic
  $ipconf = New-AzVirtualNetworkGatewayIpConfig -Name $gwipconfName -Subnet $subnet -PublicIpAddress $pip
  $deploymentkickofftime = get-date -format "hh:mm"
  
  New-AzVirtualNetworkGateway -Name $gwname -ResourceGroupName $rgfordeployment -Location $regionfordeployment -IpConfigurations $ipconf -GatewayType Expressroute -GatewaySku Standard -AsJob

  clear-host

   Write-Host -foregroundcolor Magenta "
   The Virtal Network Gateway $gwname deployment is underway and will take approximately 30 minutes
   
   The start time of the deployment was $deploymentkickofftime
   
   The status of the deployment will update every 2 minutes ... please wait ... 
   "
   
   Start-Sleep -Seconds 120
   
   # Checks Deployment Status ################################
   
   # $provisioningstate = Get-AzVirtualNetworkGateway -ResourceGroupName $rgfordeployment
   # $currentprovisioningstate = $provisioningstate.ProvisioningState
   $currentprovisioningstate = "Started"
   $timeStamp = Get-Date -Format "hh:mm"
   
   while ("Succeeded" -ne $currentprovisioningstate)
   {
      $timeStamp = Get-Date -Format "hh:mm"
      "$timestamp - Current Status: $currentprovisioningstate "
      Start-Sleep -Seconds 120
      $provisioningstate = Get-AzVirtualNetworkGateway -ResourceGroupName $rgfordeployment
      $currentprovisioningstate = $provisioningstate.ProvisioningState
   } 
   
   if ("Succeeded" -eq $currentprovisioningstate)
   {
   Write-host -ForegroundColor Green "$timestamp - Current Status: $currentprovisioningstate"
   
   $exrgwtouse = $gwname

# Connects AVS to vNet ExR GW ################################

$myprivatecloud = Get-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment
$peerid = $myprivatecloud.CircuitExpressRouteId
$pcname = $myprivatecloud.name 
Write-Host = "
Please Wait ... Generating Authorization Key"
$exrauthkey = New-AzVMWareAuthorization -Name "$pcname-authkey" -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment 
$exrgwtouse = Get-AzVirtualNetworkGateway -ResourceGroupName $rgfordeployment -Name $exrgwtouse
Write-Host = "
Please Wait ... Connecting Azure VMware Solution Private Cloud $pcname to Azure Virtual Network Gateway "$exrgwtouse.name" ... this may take a few minutes."
New-AzVirtualNetworkGatewayConnection -Name "$pcname-AVS-ExR-Connection" -ResourceGroupName $rgfordeployment -Location $regionfordeployment -VirtualNetworkGateway1 $exrgwtouse -PeerId $peerid -ConnectionType ExpressRoute -AuthorizationKey $exrauthkey.Key
 
# Checks Deployment Status ################################

$provisioningstate = Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.ProvisioningState
$timeStamp = Get-Date -Format "hh:mm"

while ("Succeeded" -ne $currentprovisioningstate)
{
  $timeStamp = Get-Date -Format "hh:mm"
  "$timestamp - Current Status: $currentprovisioningstate "
  Start-Sleep -Seconds 20
  $provisioningstate = Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $rgfordeployment
  $currentprovisioningstate = $provisioningstate.ProvisioningState
} 

if ("Succeeded" -eq $currentprovisioningstate)
{
Write-host -ForegroundColor Green "
Success"

}
   
   }
}
########## Option 2 Use an existing Azure Virtual Network and Create an ExpressRoute Gateway ##################

if ("2" -eq $vnetandexr) {

# Define vNet  #######################################

Clear-Host

$VNETs = Get-AzVirtualNetwork
$Count = 0

foreach ($vnet in $VNETs) {
   $VNETname = $vnet.Name
   Write-Host "$Count - $VNETname"
   $Count++
}

$vnetselection = Read-Host -Prompt "
Select the number which corresponds to the Virtual Network where the Virtual Network Gateway for the Azure VMware Solution Private Cloud Express Route will be deployed"
$vnettouse = $VNETs["$vnetselection"].Name

# CREATES THE GATEWAY SUBNET AND EXR GATEWAY ################################

$vnet = Get-AzVirtualNetwork -Name $vnettouse -ResourceGroupName $rgfordeployment
Add-AzVirtualNetworkSubnetConfig -Name $gatewaysubnetname -VirtualNetwork $vnet -AddressPrefix $gwsubnetprefix
$vnet = Set-AzVirtualNetwork -VirtualNetwork $vnet
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $gatewaysubnetname -VirtualNetwork $vnet
$pip = New-AzPublicIpAddress -Name $gwipName -ResourceGroupName $rgfordeployment -Location $regionfordeployment -AllocationMethod Dynamic
$ipconf = New-AzVirtualNetworkGatewayIpConfig -Name $gwipconfName -Subnet $subnet -PublicIpAddress $pip
$deploymentkickofftime = get-date -format "hh:mm"

New-AzVirtualNetworkGateway -Name $gwname -ResourceGroupName $rgfordeployment -Location $regionfordeployment -IpConfigurations $ipconf -GatewayType Expressroute -GatewaySku Standard -AsJob

clear-host

Write-Host -foregroundcolor Magenta "
The Virtal Network Gateway $gwname deployment is underway and will take approximately 30 minutes

The start time of the deployment was $deploymentkickofftime

The status of the deployment will update every 2 minutes ... please wait ... 
"

Start-Sleep -Seconds 120

# Checks Deployment Status ################################

$provisioningstate = Get-AzVirtualNetworkGateway -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.ProvisioningState
$timeStamp = Get-Date -Format "hh:mm"

while ("Succeeded" -ne $currentprovisioningstate)
{
  $timeStamp = Get-Date -Format "hh:mm"
  "$timestamp - Current Status: $currentprovisioningstate "
  Start-Sleep -Seconds 120
  $provisioningstate = Get-AzVirtualNetworkGateway -ResourceGroupName $rgfordeployment
  $currentprovisioningstate = $provisioningstate.ProvisioningState
} 

if ("Succeeded" -eq $currentprovisioningstate)
{
Write-host -ForegroundColor Green "$timestamp - Current Status: $currentprovisioningstate"


$exrgwtouse = $gwname

# Connects AVS to vNet ExR GW ################################

$myprivatecloud = Get-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment
$peerid = $myprivatecloud.CircuitExpressRouteId
$pcname = $myprivatecloud.name 
Write-Host = "
Please Wait ... Generating Authorization Key"
$exrauthkey = New-AzVMWareAuthorization -Name "$pcname-authkey" -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment 
$exrgwtouse = Get-AzVirtualNetworkGateway -ResourceGroupName $rgfordeployment -Name $exrgwtouse
Write-Host = "
Please Wait ... Connecting Azure VMware Solution Private Cloud $pcname to Azure Virtual Network Gateway "$exrgwtouse.name" ... this may take a few minutes."
New-AzVirtualNetworkGatewayConnection -Name "$pcname-AVS-ExR-Connection" -ResourceGroupName $rgfordeployment -Location $regionfordeployment -VirtualNetworkGateway1 $exrgwtouse -PeerId $peerid -ConnectionType ExpressRoute -AuthorizationKey $exrauthkey.Key
 
# Checks Deployment Status ################################

$provisioningstate = Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.ProvisioningState
$timeStamp = Get-Date -Format "hh:mm"

while ("Succeeded" -ne $currentprovisioningstate)
{
  $timeStamp = Get-Date -Format "hh:mm"
  "$timestamp - Current Status: $currentprovisioningstate "
  Start-Sleep -Seconds 20
  $provisioningstate = Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $rgfordeployment
  $currentprovisioningstate = $provisioningstate.ProvisioningState
} 

if ("Succeeded" -eq $currentprovisioningstate)
{
Write-host -ForegroundColor Green "
Success"

}
}
}

########## Option 3 Use an existing ExpressRoute Gateway ################

    if ("3" -eq $vnetandexr) {

# Pick the ExR Gateway to use ###############################

Clear-Host
$exrgws = Get-AzVirtualNetworkGateway -ResourceGroupName $rgfordeployment
    $Count = 0
    
     foreach ($exrgw in $exrgws) {
        $exrgwlist = $exrgw.Name
        Write-Host "
        $Count - $exrgwlist"
        $Count++
     }
     
    
     $exrgwselection = Read-Host -Prompt "
Select the number which corresponds to the ExpressRoute Gateway which will be use to connect your Azure VMware Solution ExpressRoute to"
    $exrgwtouse = $exrgws["$exrgwselection"].Name

# Connects AVS to vNet ExR GW ################################

$myprivatecloud = Get-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment
$peerid = $myprivatecloud.CircuitExpressRouteId
$pcname = $myprivatecloud.name 
Write-Host = "
Please Wait ... Generating Authorization Key"
$exrauthkey = New-AzVMWareAuthorization -Name "$pcname-authkey" -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment 
$exrgwtouse = Get-AzVirtualNetworkGateway -ResourceGroupName $rgfordeployment -Name $exrgwtouse
Write-Host = "
Please Wait ... Connecting Azure VMware Solution Private Cloud $pcname to Azure Virtual Network Gateway "$exrgwtouse.name" ... this may take a few minutes."
New-AzVirtualNetworkGatewayConnection -Name "$pcname-AVS-ExR-Connection" -ResourceGroupName $rgfordeployment -Location $regionfordeployment -VirtualNetworkGateway1 $exrgwtouse -PeerId $peerid -ConnectionType ExpressRoute -AuthorizationKey $exrauthkey.Key
 
# Checks Deployment Status ################################

$provisioningstate = Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.ProvisioningState
$timeStamp = Get-Date -Format "hh:mm"

while ("Succeeded" -ne $currentprovisioningstate)
{
  $timeStamp = Get-Date -Format "hh:mm"
  "$timestamp - Current Status: $currentprovisioningstate "
  Start-Sleep -Seconds 20
  $provisioningstate = Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $rgfordeployment
  $currentprovisioningstate = $provisioningstate.ProvisioningState
} 

if ("Succeeded" -eq $currentprovisioningstate)
{
Write-host -ForegroundColor Green "
Success"

}
    }


        