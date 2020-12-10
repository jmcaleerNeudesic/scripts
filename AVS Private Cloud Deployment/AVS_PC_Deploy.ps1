# Author: Trevor Davis
# Twitter: @vTrevorDavis


# Powershell 7 Is Required



#######################################
# Define SKU w/ AVS
# at the moment, that is the only sku, so hard-coding this into the script.
#######################################
$skus = "AV36"


#######################################
# Define Azure Regions w/ AVS
#######################################
$regions = "
australiaeast
westeurope
eastus
westus"

#######################################
# Connect To Azure
#######################################
Clear-Host
$sub = Read-Host -Prompt "What is the Subscription ID where you want to deploy the Azure VMware Solution Private Cloud?"

$regions
$region = Read-Host -Prompt "
What region will the Azure VMware Solution Private Cloud be deployed?
  
Type a region exactly at it appears from the list above"

#######################################
# Validate Subscription Readiness for AVS
#######################################
clear-host

[int]$Time = 5
$Lenght = $Time / 100
For ($Time; $Time -gt 0; $Time--) {
$min = [int](([string]($Time/60)).split('.')[0])
clear-host
$seconds = " "  + ($Time % 60) + " "
Write-Host -ForegroundColor Green  "To validate subscription readiness for Azure VMware Solution Private Cloud you will need to log into Azure....please wait" 

# Deployment of Azure VMware Solution will continue in $seconds seconds""
Start-Sleep 1}



Connect-AzAccount -Subscription $sub

$quota = Test-AzVMWareLocationQuotaAvailability -Location $region

if ("Enabled" -eq $quota.Enabled)
{


[int]$Time = 10
$Lenght = $Time / 100
For ($Time; $Time -gt 0; $Time--) {
$min = [int](([string]($Time/60)).split('.')[0])
clear-host
$seconds = " "  + ($Time % 60) + " "
Write-Host -ForegroundColor Yellow  "$sub has been validated, Azure VMware Solution is ENABLED on this subscription ... please wait"
Start-Sleep 1
}

}


Else
{
Write-Host -ForegroundColor Red "
Subscription $sub is NOT ENABLED for Azure VMware Solution, please visit the following site for guidance on how to get this service enabled for your subscription.

https://docs.microsoft.com/en-us/azure/azure-vmware/enable-azure-vmware-solution"

}


#######################################
# Define Resource Group
#######################################

Clear-Host
$rgnew = Read-Host -Prompt "Are you going to create a new Resource Group for or use an existing Resource Group for Azure VMware Solution Private Cloud?

N = Create a New Resource Group
E = Use an existing resource group

Enter Your Reponse (N or E)"
clear-host



if ( "E" -eq $rgnew )
{
$RGs = Get-AzResourceGroup
$Count = 0

 foreach ($rg in $RGs) {
    $RGname = $rg.ResourceGroupName
    Write-Host "$Count - $RGname"
    $Count++
 }

$rgselection = Read-Host -Prompt "
Identify the Resource Group where you want to deploy the Azure VMware Solution Private Cloud.
Choose the number to the left of the Resource Group name"
$rgtouse = $RGs["$rgselection"].ResourceGroupName
$rgfordeployment = $rgtouse

}
else
{
$rgnewname = Read-Host -Prompt "What name do you want to give to the new Resource Group?"
$rgfordeployment = $rgnewname
New-AzResourceGroup -Name $rgnewname -Location $region

 }

#######################################
# Define Resource Name
#######################################

clear-host
$resourcename = Read-Host -Prompt "Provide a Resource Name for the Azure VMware Solution Private Cloud.
This is the name of the private cloud which will appear in the Azure portal

Resource Name"

#######################################
# Number of Hosts to Deploy
#######################################
$numberofhosts = 3

#######################################
# Enable or Disable Internet
#######################################
Clear-Host
Write-Host "By default, all traffic that is sourced from the Internet of course is blocked, i.e.,  firewall deny all inbound.
You can, if you need, at a later time configure inbound access to Azure VMware Solution Private Cloud VMs.

However, you can choose to ENABLE or DISABLE access to the Internet from your Azure VMware Solution Private Cloud.  
Meaning, do you want the VMs in your Private Cloud to be able to source a connection to an Internet destination?
"

$internetenabledyesorno = Read-Host -Prompt "Do you want Internet access enabled for your Private Cloud? You can always change this configuration after deployment. (Y/N)"
if("Y" -eq $internetenabledyesorno)
{$internet = "Enabled"}
else 
{$internet = "Disabled"}

#######################################
# Define vCenter Password
#######################################
Clear-Host
$passwordsuccess = 0
while($passwordsuccess -eq 0)
{
$vcenterpassword1 = Read-Host -Prompt "Provide a password that will be used for Azure VMware Solution Private Cloud vCenter Server access" -MaskInput 
$vcenterpassword2 = Read-Host -Prompt "Re-Enter the vCenter password" -MaskInput

if ($vcenterpassword1 -eq $vcenterpassword2) 
{
$vcenterpassword = $vcenterpassword1
$passwordsuccess = 1

}
else
{Write-Host ""
"The Passwords Do Not Match
"}
}

#######################################
# Define NSX Password
#######################################
Clear-Host
$passwordsuccess = 0
while($passwordsuccess -eq 0)
{
$nsxpassword1 = Read-Host -Prompt "Provide a password that will be used for Azure VMware Solution Private Cloud NSX-T Manager access" -MaskInput
$nsxpassword2 = Read-Host -Prompt "Re-Enter the NSX-T password" -MaskInput

if ($nsxpassword1 -eq $nsxpassword2) 
{
$nsxpassword = $nsxpassword1
$passwordsuccess = 1

}
else
{Write-Host ""
"The Passwords Do Not Match
"}
}

#######################################
# /22 network definition
# CHALLENGE how do we validate that it's a valid /22 network
#######################################

Clear-Host
$addressblock = Read-Host -Prompt "
To deploy the Azure VMware Solution Private Cloud a /22 network address block must be provided (example 192.168.8.0/22).  Is must be a /22, we cannot accept any other CIDR block size.  This network block is then used to deploy the Azure VMware Solution Private Cloud infrastructure networks, such as vMotion, vSAN, Management, etc..

/22 Address Block (please type in this format x.x.x.x/22)"



#######################################
# Confirm Deployment Values
#######################################
clear-host
Write-Host -ForegroundColor Yellow "---- Confirm The Following Is Accurate ---- "
    Write-Host -NoNewline -ForegroundColor Green "Subscription: "
    Write-Host -ForegroundColor White $sub

    Write-Host -NoNewline -ForegroundColor Green "Resource Group: "
    Write-Host -ForegroundColor White $rgfordeployment
    
    Write-Host -NoNewline -ForegroundColor Green "Location: "
    Write-Host -ForegroundColor White $region

    Write-Host -NoNewline -ForegroundColor Green "Resource Name: "
    Write-Host -ForegroundColor White $resourcename
    
    Write-Host -NoNewline -ForegroundColor Green "SKU: "
    Write-Host -ForegroundColor White $skus

    Write-Host -NoNewline -ForegroundColor Green "Hosts: "
    Write-Host -ForegroundColor White $numberofhosts "(Additional Hosts can be added after initial deployment as needed)."

#    Write-Host -NoNewline -ForegroundColor Green "vCenter Password: "
#    Write-Host -ForegroundColor White $vcenterpassword

#    Write-Host -NoNewline -ForegroundColor Green "NSX Password: "
#    Write-Host -ForegroundColor White $nsxpassword

    Write-Host -NoNewline -ForegroundColor Green "Address Block: "
    Write-Host -ForegroundColor White $addressblock

    Write-Host -NoNewline -ForegroundColor Green "Internet Enabled/Disabled: 
    "
    Write-Host -ForegroundColor White $internet


#######################################
# Deployment of AVS Private Cloud
#######################################
write-host "Deployment will take approximately 3 hours, this Powershell script will pause until the deployment completes.

When the Private Cloud deployment completes, you will be notified." -foregroundcolor Magenta
 
$begindeployment = Read-Host -Prompt "
Would you like to begin the Azure VMware Solution deployment (Y/N)"
 
if ("y" -eq $begindeployment)
{

$deploymentkickofftime = get-date -format "hh:mm"
write-host "
The start time of the deployment was $deploymentkickofftime
"

New-AzVMWarePrivateCloud -Name $resourcename -ResourceGroupName $rgfordeployment -SubscriptionId $sub -NetworkBlock $addressblock -Sku $skus -Location $region -NsxtPassword $nsxpassword -VcenterPassword $vcenterpassword -managementclustersize $numberofhosts -Internet $internet -NoWait 

$mypcinfo = get-azvmwareprivatecloud -Name $resourcename -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $mypcinfo.ProvisioningState
$vcenterurl = $mypcinfo.EndpointVcsa
$nsxturl = $mypcinfo.EndpointNsxtManager
$hcxmanagerurl = $mypcinfo.EndpointHcxCloudManager
$pcname = $mypcinfo.Name
$pclocation = $mypcinfo.Location
$pcinternet = $mypcinfo.Internet
$pcclustersize = $mypcinfo.ManagementClusterSize
$pcsku = $mypcinfo.SkuName

}


if ("Succeeded" -eq $currentprovisioningstate)
{
$timeStamp = Get-Date -Format "hh:mm"
write-host -ForegroundColor Green "The Azure VMware Solution Private Cloud has been successfully deployed."
write-host "=======================================================================
"
Write-Host -NoNewline -ForegroundColor Green "Private Cloud Name: "
Write-Host -ForegroundColor White $pcname
Write-Host -NoNewline -ForegroundColor Green "Azure Region: "
Write-Host -ForegroundColor White $pclocation
Write-Host -NoNewline -ForegroundColor Green "Private Cloud Cluster Size: "
Write-Host -ForegroundColor White $pcclustersize
Write-Host -NoNewline -ForegroundColor Green "Private Cloud Cluster SKU: "
Write-Host -ForegroundColor White $pcsku
Write-Host -NoNewline -ForegroundColor Green "Internet Access From Azure VMware Solution Private Cloud VMs: "
Write-Host -ForegroundColor White $pcinternet 
write-host ""
Write-Host -NoNewline -ForegroundColor Green "vCenter IP URL: "
Write-Host -ForegroundColor White $vcenterurl
Write-Host -NoNewline -ForegroundColor Green "Username: "
Write-Host -ForegroundColor White "cloudadmin@vsphere.local"
Write-Host -NoNewline -ForegroundColor Green "Password: "
Write-Host -ForegroundColor White "The password you defined prior to deployement
"
Write-Host -NoNewline -ForegroundColor Green "NSX-T Manager URL: "
Write-Host -ForegroundColor White $nsxturl
Write-Host -NoNewline -ForegroundColor Green "Username: "
Write-Host -ForegroundColor White "admin"
Write-Host -NoNewline -ForegroundColor Green "Password: "
Write-Host -ForegroundColor White "The password you defined prior to deployement
"
Write-Host -NoNewline -ForegroundColor Green "HCX Cloud Manager URL: "
Write-Host -ForegroundColor White $hcxmanagerurl
Write-Host -NoNewline -ForegroundColor Green "Username: "
Write-Host -ForegroundColor White "cloudadmin@vsphere.local"
Write-Host -NoNewline -ForegroundColor Green "Password: "
Write-Host -ForegroundColor White "The same password as your vCenter password you defined prior to deployment
"
}

else
{
Write-Host -ForegroundColor Red "$timestamp - Current Status: $currentprovisioningstate 

There appears to be a problem with the deployment of Azure VMware Solution Private Cloud $resourcename in subscription $sub

"}

