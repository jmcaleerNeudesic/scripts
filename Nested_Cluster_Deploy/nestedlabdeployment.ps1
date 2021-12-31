#######################################################################################
# Outline Requirements 
#######################################################################################

Write-Host -ForegroundColor Green "
This script will do the following:"

Write-Host -ForegroundColor White "
- Create NSX-T T1 Gateway specifically for the nested cluster.
- Create NSX-T segment on the NSX-T T1 Gateway.
- Deploy 2-node nested vSphere Cluster on the AVS Private Cloud.
- Connect nested vSphere Cluster to the newly created NSX-T segment."

Write-Host -ForegroundColor Green "
To support this deployment the following is required:
"

Write-Host -ForegroundColor White "- Powershell 7.x"
Write-Host -ForegroundColor Yellow "  https://docs.microsoft.com/en-us/powershell/"
Write-Host -ForegroundColor White "- VMware PowerCLI"
Write-Host -ForegroundColor Yellow "  https://developer.vmware.com/web/tool/vmware-powercli"
Write-Host -ForegroundColor White "- Pre-Populated Configuraton File"
Write-Host -ForegroundColor Yellow "  https://github.com/Trevor-Davis/scripts/blob/main/Nested_Cluster_Deploy/nestedlabvariables.xlsx"
Write-Host -ForegroundColor White "- Microsoft Excel"
Write-Host -ForegroundColor White "- vSphere OVA file"
Write-Host -ForegroundColor White "- Path to vCenter Installer"
Write-Host -ForegroundColor White "- Access to an AVS Private Cloud vCenter and NSX Manager
"

Write-Host -ForegroundColor Yellow "Would you like to begin? (Y/N): " -NoNewline
$begin = Read-Host 

if ("y" -eq $begin) {

#######################################################################################
# Get NSX and vCenter Credentials 
#######################################################################################
#Write-Host -ForegroundColor Green "
#Provide the credentials for the AVS vCenter Server:" 
#$vCenterCred = Get-Credential
Write-Host -NoNewLine -ForegroundColor White "
Provide the credentials for the"
Write-Host -ForegroundColor Green " AVS NSX Manager:"
$NSXCred = Get-Credential}

else {
    Write-Host -ForegroundColor Red "
    Script has been terminated."
    Exit
}

#######################################################################################
# Browse for User Input File 
#######################################################################################
Write-Host "You will now be asked to locate the file nestedlabvariables.xlsx on your local system.  Press any key to continue ...
";
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');

   Add-Type -AssemblyName System.Windows.Forms
   $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
   [void]$FileBrowser.ShowDialog()
   $file = $FileBrowser.FileName
   $sheetName = "nestedvariables"
   $objExcel = New-Object -ComObject Excel.Application
   $workbook = $objExcel.Workbooks.Open($file)
   $sheet = $workbook.Worksheets.Item($sheetName)
   $objExcel.Visible=$false

   #Declare the  positions
   $rowVIServer,$colVIServer = 2,4
$rowVIUsername,$colVIUsername = 3,4
$rowVIPassword,$colVIPassword = 4,4
$rowNSXManagerIP,$colNSXManagerIP = 5,4
$rowAVSDatacenter,$colAVSDatacenter = 6,4
$rowAVSCluster,$colAVSCluster = 7,4
$rowAVSDatastore,$colAVSDatastore = 8,4
$rowAVSResourcePool,$colAVSResourcePool = 9,4
$rowtier0gw,$coltier0gw = 10,4
$rowtier1gw,$coltier1gw = 11,4
$rowtransportzoneid,$coltransportzoneid = 12,4
$rowNSXSegName,$colNSXSegName = 13,4
$rowNSXSegNetwork,$colNSXSegNetwork = 14,4
$rowNSXSegNetmask,$colNSXSegNetmask = 15,4
$rowNSXSegGateway,$colNSXSegGateway = 16,4
$rowadminpassword,$coladminpassword = 17,4
$rowesxi1hostname,$colesxi1hostname = 18,4
$rowesxi2hostname,$colesxi2hostname = 19,4
$rowesxi1ip,$colesxi1ip = 20,4
$rowesxi2ip,$colesxi2ip = 21,4
$rowNestedESXivCPU,$colNestedESXivCPU = 22,4
$rowNestedESXivMEM,$colNestedESXivMEM = 23,4
$rowVCSASSODomainName,$colVCSASSODomainName = 24,4
$rowVCSADeploymentSize,$colVCSADeploymentSize = 25,4
$rowVCSADisplayName,$colVCSADisplayName = 26,4
$rowVCSAIPAddress,$colVCSAIPAddress = 27,4
$rowVCSAGateway,$colVCSAGateway = 28,4
$rowVCSAPrefix,$colVCSAPrefix = 29,4
$rownestedssh,$colnestedssh = 30,4
$rowdhcpnetwork,$coldhcpnetwork = 31,4
$rowdhcprange,$coldhcprange = 32,4
$rowDHCPServerAddress,$colDHCPServerAddress = 33,4
$rowEdgeClusterID,$colEdgeClusterID = 34,4
$rowdhcpservername,$coldhcpservername = 35,4
$rowNestedClusterDNS,$colNestedClusterDNS = 36,4
$rownestedntp,$colnestedntp = 37,4
$rowVMFolder,$colVMFolder = 38,4
$rowNewVCDatacenterName,$colNewVCDatacenterName = 39,4
$rowNewVCVSANClusterName,$colNewVCVSANClusterName = 40,4
$rowNewVCVDSName,$colNewVCVDSName = 41,4
$rowNewVCWorkloadDVPGName,$colNewVCWorkloadDVPGName = 42,4


   

    
   #read in variables
   $VIServer = $sheet.Cells.Item($rowVIServer,$colVIServer).text
   $VIUsername = $sheet.Cells.Item($rowVIUsername,$colVIUsername).text
   $VIPassword = $sheet.Cells.Item($rowVIPassword,$colVIPassword).text
   $NSXManagerIP = $sheet.Cells.Item($rowNSXManagerIP,$colNSXManagerIP).text
   $AVSDatacenter = $sheet.Cells.Item($rowAVSDatacenter,$colAVSDatacenter).text
   $AVSCluster = $sheet.Cells.Item($rowAVSCluster,$colAVSCluster).text
   $AVSDatastore = $sheet.Cells.Item($rowAVSDatastore,$colAVSDatastore).text
   $AVSResourcePool = $sheet.Cells.Item($rowAVSResourcePool,$colAVSResourcePool).text
   $tier0gw = $sheet.Cells.Item($rowtier0gw,$coltier0gw).text
   $tier1gw = $sheet.Cells.Item($rowtier1gw,$coltier1gw).text
   $transportzoneid = $sheet.Cells.Item($rowtransportzoneid,$coltransportzoneid).text
   $NSXSegName = $sheet.Cells.Item($rowNSXSegName,$colNSXSegName).text
   $NSXSegNetwork = $sheet.Cells.Item($rowNSXSegNetwork,$colNSXSegNetwork).text
   $NSXSegNetmask = $sheet.Cells.Item($rowNSXSegNetmask,$colNSXSegNetmask).text
   $NSXSegGateway = $sheet.Cells.Item($rowNSXSegGateway,$colNSXSegGateway).text
   $adminpassword = $sheet.Cells.Item($rowadminpassword,$coladminpassword).text
   $esxi1hostname = $sheet.Cells.Item($rowesxi1hostname,$colesxi1hostname).text
   $esxi2hostname = $sheet.Cells.Item($rowesxi2hostname,$colesxi2hostname).text
   $esxi1ip = $sheet.Cells.Item($rowesxi1ip,$colesxi1ip).text
   $esxi2ip = $sheet.Cells.Item($rowesxi2ip,$colesxi2ip).text
   $NestedESXivCPU = $sheet.Cells.Item($rowNestedESXivCPU,$colNestedESXivCPU).text
   $NestedESXivMEM = $sheet.Cells.Item($rowNestedESXivMEM,$colNestedESXivMEM).text
   $VCSASSODomainName = $sheet.Cells.Item($rowVCSASSODomainName,$colVCSASSODomainName).text
   $VCSADeploymentSize = $sheet.Cells.Item($rowVCSADeploymentSize,$colVCSADeploymentSize).text
   $VCSADisplayName = $sheet.Cells.Item($rowVCSADisplayName,$colVCSADisplayName).text
   $VCSAIPAddress = $sheet.Cells.Item($rowVCSAIPAddress,$colVCSAIPAddress).text
   $VCSAGateway = $sheet.Cells.Item($rowVCSAGateway,$colVCSAGateway).text
   $VCSAPrefix = $sheet.Cells.Item($rowVCSAPrefix,$colVCSAPrefix).text
   $nestedssh = $sheet.Cells.Item($rownestedssh,$colnestedssh).text
   $dhcpnetwork = $sheet.Cells.Item($rowdhcpnetwork,$coldhcpnetwork).text
   $dhcprange = $sheet.Cells.Item($rowdhcprange,$coldhcprange).text
   $DHCPServerAddress = $sheet.Cells.Item($rowDHCPServerAddress,$colDHCPServerAddress).text
   $EdgeClusterID = $sheet.Cells.Item($rowEdgeClusterID,$colEdgeClusterID).text
   $dhcpservername = $sheet.Cells.Item($rowdhcpservername,$coldhcpservername).text
   $NestedClusterDNS = $sheet.Cells.Item($rowNestedClusterDNS,$colNestedClusterDNS).text
   $nestedntp = $sheet.Cells.Item($rownestedntp,$colnestedntp).text
   $VMFolder = $sheet.Cells.Item($rowVMFolder,$colVMFolder).text
   $NewVCDatacenterName = $sheet.Cells.Item($rowNewVCDatacenterName,$colNewVCDatacenterName).text
   $NewVCVSANClusterName = $sheet.Cells.Item($rowNewVCVSANClusterName,$colNewVCVSANClusterName).text
   $NewVCVDSName = $sheet.Cells.Item($rowNewVCVDSName,$colNewVCVDSName).text
   $NewVCWorkloadDVPGName = $sheet.Cells.Item($rowNewVCWorkloadDVPGName,$colNewVCWorkloadDVPGName).text
   
   

      
   #close excel file
   $objExcel.quit()

########################################
# Locate the ESXi OVA File
########################################

 
   
Write-Host "
"
Write-Host -NoNewLine -ForegroundColor White "
   You will now be asked to locate the"
   Write-Host -NoNewLine -ForegroundColor Green " ESXi OVA File on your local system."
   Write-Host -NoNewline -ForegroundColor White "  Press any key to continue ..."

  $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');

   Add-Type -AssemblyName System.Windows.Forms
   $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
   [void]$FileBrowser.ShowDialog()
   $NestedESXiApplianceOVA = $FileBrowser.FileName

# $NestedESXiApplianceOVA = "C:\users\avs-admin\Downloads\nested\Nested_ESXi6.7u3_Appliance_Template_v1.ova"

########################################
# ID the vCenter Installer Path
########################################

Write-Host "
"
Write-Host -NoNewLine -ForegroundColor White "
You will now be prompted to"
Write-Host -NoNewLine -ForegroundColor Green " identify the folder of the vCenter installer."
Write-Host -NoNewline -ForegroundColor White "  Press any key to continue ..."


$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

   Add-Type -AssemblyName System.Windows.Forms
   $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
   [void]$FolderBrowser.ShowDialog()
   $VCSAInstallerPath = $FolderBrowser.SelectedPath
   
   


########################################
# Create T1 GW
########################################
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")

$body = "{
`n    `"tier0_path`": `"/infra/tier-0s/$tier0gw`",
`n    `"failover_mode`": `"NON_PREEMPTIVE`",
`n    `"enable_standby_relocation`": false,
`n    `"route_advertisement_types`": [
`n        `"TIER1_LB_VIP`",
`n        `"TIER1_CONNECTED`",
`n        `"TIER1_IPSEC_LOCAL_ENDPOINT`",
`n        `"TIER1_NAT`",
`n        `"TIER1_LB_SNAT`",
`n        `"TIER1_DNS_FORWARDER_IP`",
`n        `"TIER1_STATIC_ROUTES`"
`n    ],
`n    `"force_whitelisting`": false,
`n    `"default_rule_logging`": false,
`n    `"disable_firewall`": false,
`n    `"ipv6_profile_paths`": [
`n        `"/infra/ipv6-ndra-profiles/default`",
`n        `"/infra/ipv6-dad-profiles/default`"
`n    ],
`n    `"pool_allocation`": `"ROUTING`",
`n    `"resource_type`": `"Tier1`",
`n    `"id`": `"$tier1gw`",
`n    `"display_name`": `"$tier1gw`",
`n    `"path`": `"/infra/tier-1s/$tier1gw`",
`n    `"relative_path`": `"$tier1gw`",
`n    `"parent_path`": `"/infra`",
`n    `"marked_for_delete`": false,
`n    `"overridden`": false
`n}"

$response = Invoke-RestMethod https://"$NSXManagerIP"/policy/api/v1/infra/tier-1s/"$tier1gw" -Method 'PATCH' -Headers $headers -Body $body -Authentication Basic -Credential $NSXCred -SkipCertificateCheck
$response | ConvertTo-Json

######
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")


$body = "        {
`n            `"edge_cluster_path`": `"/infra/sites/default/enforcement-points/default/edge-clusters/8c1ad058-f8a2-49c1-9d16-6098c596457d`",
`n            `"bfd_profile_path`": `"/infra/bfd-profiles/default`",
`n            `"resource_type`": `"LocaleServices`",
`n            `"id`": `"$tier1gw-LOCALE-SERVICE`",
`n            `"display_name`": `"$tier1gw-LOCALE-SERVICE`",
`n            `"path`": `"/infra/tier-1s/$tier1gw/locale-services/$tier1gw-LOCALE-SERVICE`",
`n            `"relative_path`": `"$tier1gw-LOCALE-SERVICE`",
`n            `"parent_path`": `"/infra/tier-1s/$tier1gw`",
`n            `"marked_for_delete`": false,
`n            `"overridden`": false,
`n            `"_system_owned`": false,
`n            `"_protection`": `"REQUIRE_OVERRIDE`"
`n        }
`n"

$response = Invoke-RestMethod https://"$NSXManagerIP"/policy/api/v1/infra/tier-1s/"$tier1gw"/locale-services/"$tier1gw"-LOCALE-SERVICE -Method 'PUT' -Headers $headers -Body $body -Authentication Basic -Credential $NSXCred -SkipCertificateCheck
$response | ConvertTo-Json


###Create DHCP Server

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")



$body = "{
`n  `"server_address`": `"$DHCPServerAddress`",
`n  `"lease_time`": 86400,
`n        `"edge_cluster_path`": `"/infra/sites/default/enforcement-points/default/edge-clusters/$EdgeClusterID`",
`n        `"resource_type`": `"DhcpServerConfig`"
`n
`n
`n}"

$response = Invoke-RestMethod https://"$NSXManagerIP"/policy/api/v1/infra/dhcp-server-configs/"$dhcpservername" -Method 'PATCH' -Headers $headers -Body $body -Authentication Basic -Credential $NSXCred -SkipCertificateCheck
$response | ConvertTo-Json

########################################
# LinkDHCP to T1
########################################
   

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")

$body = "{ `"dhcp_config_paths`": [
`n        `"/infra/dhcp-server-configs/$dhcpservername`"
`n    ]}"

$response = Invoke-RestMethod https://$NSXManagerIP/policy/api/v1/infra/tier-1s/$tier1gw -Method 'PATCH' -Headers $headers -Body $body -SkipCertificateCheck -Authentication Basic -Credential $NSXCred
$response | ConvertTo-Json

#######################################
# Create Segments
########################################



$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")

$body = "  {
`n    `"display_name`":`"$NSXSegName`",
`n    `"subnets`": [
`n      {
`n        `"gateway_address`": `"$NSXSegGateway`",
`n        `"dhcp_ranges`":[`"$dhcprange`"],
`n        `"dhcp_config`":{
`n            `"resource_type`": `"SegmentDhcpV4Config`",
`n            `"lease_time`": 86400,
`n            `"dns_servers`":[`"$NestedClusterDNS`"]
`n        },
`n       `"network`": `"$NSXSegNetwork`"
`n      }
`n    ],
`n    `"connectivity_path`": `"/infra/tier-1s/$tier1gw`",
`n    `"transport_zone_path`": `"/infra/sites/default/enforcement-points/default/transport-zones/$transportzoneid`"
`n
`n  }"

$response = Invoke-RestMethod https://$NSXManagerIP/policy/api/v1/infra/segments/$NSXSegName -Method 'PUT' -Headers $headers -Authentication Basic -Credential $NSXCred -Body $body -SkipCertificateCheck
$response | ConvertTo-Json

Write-Host "Pausing the Script for 15 Seconds"
Start-Sleep -s 15



<#
# Countdown
########################################
$x = 1*30
$length = $x / 100
while($x -gt 0) {
  $min = [int](([string]($x/60)).split('.')[0])
  $text = " " + $min + " minutes " + ($x % 60) + " seconds left"
  Write-Progress "Making Sure All the NSX Configurations Have Been Applied ..." -status $text -perc ($x/$length)
  start-sleep -s 1
  $x--
  
}
Clear-Host
#>

$SddcProvider = "Microsoft"


# Connect to vCenter
Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false
Connect-VIServer $VIServer -User $VIUsername -Password $VIPassword -WarningAction SilentlyContinue


$PhotonNFSOVA = $NestedESXiApplianceOVA



# Nested ESXi VMs to deploy
$NestedESXiHostnameToIPs = @{
    "$esxi1hostname" = "$esxi1ip"
    "$esxi2hostname" = "$esxi2ip"
    }


$NewVCWorkloadVMFormat = "$NewVCWorkloadDVPGName-" # workload-01,02,03,etc

$NewVcWorkloadVMCount = 2
$VMVMFS = "false"

#############################################################################################

# Advanced Configurations
# Set to 1 only if you have DNS (forward/reverse) for ESXi hostnames
$addHostByDnsName = 0


$debug = $true
$verboseLogFile = "nested-sddc-lab-deployment.log"
$random_string = -join ((65..90) + (97..122) | Get-Random -Count 8 | % {[char]$_})
$VAppName = "Nested-SDDC-Lab-$random_string"

$preCheck = 1
$confirmDeployment = 0
$deployNFSVM = 0
$deployNestedESXiVMs = 1
$deployVCSA = 1
$setupNewVC = 1
$addESXiHostsToVC = 1
$configureESXiStorage = 0
$configureVDS = 1
$clearHealthCheckAlarm = 1
$moveVMsIntovApp = 1
$deployWorkload = 0

$vcsaSize2MemoryStorageMap = @{
"tiny"=@{"cpu"="2";"mem"="12";"disk"="415"};
"small"=@{"cpu"="4";"mem"="19";"disk"="480"};
"medium"=@{"cpu"="8";"mem"="28";"disk"="700"};
"large"=@{"cpu"="16";"mem"="37";"disk"="1065"};
"xlarge"=@{"cpu"="24";"mem"="56";"disk"="1805"}
}

$sddcProviderService = @{
    "Microsoft"="Azure VMware Solution (AVS)";
}

$supportedStorageType = @{
    "Microsoft"="NFS";

}

$esxiTotalCPU = 0
$vcsaTotalCPU = 0
$esxiTotalMemory = 0
$vcsaTotalMemory = 0
$esxiTotalStorage = 0

$StartTime = Get-Date

Function My-Logger {
    param(
    [Parameter(Mandatory=$true)]
    [String]$message
    )

    $timeStamp = Get-Date -Format "MM-dd-yyyy_hh:mm:ss"

    Write-Host -NoNewline -ForegroundColor White "[$timestamp]"
    Write-Host -ForegroundColor Green " $message"
    $logMessage = "[$timeStamp] $message"
    $logMessage | Out-File -Append -LiteralPath $verboseLogFile
}

if($preCheck -eq 1) {
    if($SddcProvider -ne "Microsoft" ) {
        Write-Host -ForegroundColor Red "`n`$SddcProvider variable is incorrectly set. ...`n"
        exit
    }

    if(!(Test-Path $NestedESXiApplianceOVA)) {
        Write-Host -ForegroundColor Red "`nUnable to find $NestedESXiApplianceOVA ...`n"
        exit
    }

    if(!(Test-Path $VCSAInstallerPath)) {
        Write-Host -ForegroundColor Red "`nUnable to find $VCSAInstallerPath ...`n"
        exit
    }

    if($supportedStorageType.$SddcProvider -eq "NFS") {
        if(!(Test-Path $PhotonNFSOVA)) {
            Write-Host -ForegroundColor Red "`nUnable to find $PhotonNFSOVA ...`n"
            exit
        }
    }

    if($deployWorkload -eq 1) {
        if(!(Test-Path $PhotonOSOVA)) {
            Write-Host -ForegroundColor Red "`nUnable to find $PhotonOSOVA ...`n"
            exit
        }
    }

    if($PSVersionTable.PSEdition -ne "Core") {
        Write-Host -ForegroundColor Red "`tPowerShell Core was not detected, please install that before continuing ... `n"
        exit
    }
}

if($confirmDeployment -eq 1) {
    Write-Host -ForegroundColor Magenta "`nPlease confirm the following configuration will be deployed:`n"

    Write-Host -ForegroundColor Yellow "---- Nested SDDC Automated Lab Deployment Configuration ---- "
    Write-Host -NoNewline -ForegroundColor Green "SDDC Provider: "
    Write-Host -ForegroundColor White $SddcProvider
    Write-Host -NoNewline -ForegroundColor Green "VMware Cloud Service: "
    Write-Host -ForegroundColor White $sddcProviderService.$SddcProvider

    Write-Host -NoNewline -ForegroundColor Green "`nNested ESXi Image Path: "
    Write-Host -ForegroundColor White $NestedESXiApplianceOVA
    Write-Host -NoNewline -ForegroundColor Green "VCSA Image Path: "
    Write-Host -ForegroundColor White $VCSAInstallerPath

    if($supportedStorageType.$SddcProvider -eq "NFS") {
        Write-Host -NoNewline -ForegroundColor Green "NFS Image Path: "
        Write-Host -ForegroundColor White $PhotonNFSOVA
    }

    if($deployWorkload -eq 1) {
        Write-Host -NoNewline -ForegroundColor Green "PhotonOS Image Path: "
        Write-Host -ForegroundColor White $PhotonOVA
    }

    Write-Host -ForegroundColor Yellow "`n---- vCenter Server Deployment Target Configuration ----"
    Write-Host -NoNewline -ForegroundColor Green "vCenter Server Address: "
    Write-Host -ForegroundColor White $VIServer
    Write-Host -NoNewline -ForegroundColor Green "VM Network: "
    Write-Host -ForegroundColor White $NSXSegName

    Write-Host -NoNewline -ForegroundColor Green "VM Cluster: "
    Write-Host -ForegroundColor White $AVSCluster
    Write-Host -NoNewline -ForegroundColor Green "VM Resource Pool: "
    Write-Host -ForegroundColor White $AVSResourcePool
    Write-Host -NoNewline -ForegroundColor Green "VM Storage: "
    Write-Host -ForegroundColor White $AVSDatastore
    Write-Host -NoNewline -ForegroundColor Green "VM vApp: "
    Write-Host -ForegroundColor White $VAppName

    Write-Host -ForegroundColor Yellow "`n---- vESXi Configuration ----"
    Write-Host -NoNewline -ForegroundColor Green "# of Nested ESXi VMs: "
    Write-Host -ForegroundColor White $NestedESXiHostnameToIPs.count
    Write-Host -NoNewline -ForegroundColor Green "vCPU: "
    Write-Host -ForegroundColor White $NestedESXivCPU
    Write-Host -NoNewline -ForegroundColor Green "vMEM: "
    Write-Host -ForegroundColor White "$NestedESXivMEM GB"

    if($supportedStorageType.$SddcProvider -eq "NFS") {
        Write-Host -NoNewline -ForegroundColor Green "NFS Storage: "
        Write-Host -ForegroundColor White "$NFSVMCapacity GB"
    } else {
        Write-Host -NoNewline -ForegroundColor Green "vSAN Caching VMDK: "
        Write-Host -ForegroundColor White "$NestedESXiCachingvDisk GB"
        Write-Host -NoNewline -ForegroundColor Green "vSAN Capacity VMDK: "
        Write-Host -ForegroundColor White "$NestedESXiCapacityvDisk GB"
    }

    Write-Host -NoNewline -ForegroundColor Green "IP Address(s): "
    Write-Host -ForegroundColor White $NestedESXiHostnameToIPs.Values
    Write-Host -NoNewline -ForegroundColor Green "Netmask "
    Write-Host -ForegroundColor White $NSXSegNetmask
    Write-Host -NoNewline -ForegroundColor Green "Gateway: "
    Write-Host -ForegroundColor White $NSXSegGateway
    Write-Host -NoNewline -ForegroundColor Green "DNS: "
    Write-Host -ForegroundColor White $NestedClusterDNS
    Write-Host -NoNewline -ForegroundColor Green "NTP: "
    Write-Host -ForegroundColor White $nestedntp
    Write-Host -NoNewline -ForegroundColor Green "Syslog: "
    Write-Host -ForegroundColor White $VMSyslog
    Write-Host -NoNewline -ForegroundColor Green "Enable SSH: "
    Write-Host -ForegroundColor White $nestedssh

    Write-Host -ForegroundColor Yellow "`n---- VCSA Configuration ----"
    Write-Host -NoNewline -ForegroundColor Green "Deployment Size: "
    Write-Host -ForegroundColor White $VCSADeploymentSize
    Write-Host -NoNewline -ForegroundColor Green "SSO Domain: "
    Write-Host -ForegroundColor White $VCSASSODomainName
    Write-Host -NoNewline -ForegroundColor Green "Enable SSH: "
    Write-Host -ForegroundColor White $nestedssh
    Write-Host -NoNewline -ForegroundColor Green "Hostname: "
    Write-Host -ForegroundColor White $VCSAHostname
    Write-Host -NoNewline -ForegroundColor Green "IP Address: "
    Write-Host -ForegroundColor White $VCSAIPAddress
    Write-Host -NoNewline -ForegroundColor Green "Netmask "
    Write-Host -ForegroundColor White $NSXSegNetmask
    Write-Host -NoNewline -ForegroundColor Green "Gateway: "
    Write-Host -ForegroundColor White $NSXSegGateway

    $esxiTotalCPU = $NestedESXiHostnameToIPs.count * [int]$NestedESXivCPU
    $esxiTotalMemory = $NestedESXiHostnameToIPs.count * [int]$NestedESXivMEM
    if($SddcProvider -eq "Microsoft") {
        $esxiTotalStorage = [int]$NFSCapacity
    } else {
        $esxiTotalStorage = ($NestedESXiHostnameToIPs.count * [int]$NestedESXiCachingvDisk) + ($NestedESXiHostnameToIPs.count * [int]$NestedESXiCapacityvDisk)
    }
    $vcsaTotalCPU = $vcsaSize2MemoryStorageMap.$VCSADeploymentSize.cpu
    $vcsaTotalMemory = $vcsaSize2MemoryStorageMap.$VCSADeploymentSize.mem
    $vcsaTotalStorage = $vcsaSize2MemoryStorageMap.$VCSADeploymentSize.disk

    Write-Host -ForegroundColor Yellow "`n---- Resource Requirements ----"
    Write-Host -NoNewline -ForegroundColor Green "ESXi     VM CPU: "
    Write-Host -NoNewline -ForegroundColor White $esxiTotalCPU
    Write-Host -NoNewline -ForegroundColor Green " ESXi     VM Memory: "
    Write-Host -NoNewline -ForegroundColor White $esxiTotalMemory "GB "
    Write-Host -NoNewline -ForegroundColor Green "ESXi     VM Storage: "
    Write-Host -ForegroundColor White $esxiTotalStorage "GB"
    Write-Host -NoNewline -ForegroundColor Green "VCSA     VM CPU: "
    Write-Host -NoNewline -ForegroundColor White $vcsaTotalCPU
    Write-Host -NoNewline -ForegroundColor Green " VCSA     VM Memory: "
    Write-Host -NoNewline -ForegroundColor White $vcsaTotalMemory "GB "
    Write-Host -NoNewline -ForegroundColor Green "VCSA     VM Storage: "
    Write-Host -ForegroundColor White $vcsaTotalStorage "GB"

    if($supportedStorageType.$SddcProvider -eq "NFS") {
        Write-Host -NoNewline -ForegroundColor Green "NFS      VM CPU: "
        Write-Host -NoNewline -ForegroundColor White "2"
        Write-Host -NoNewline -ForegroundColor Green " NFS      VM Memory: "
        Write-Host -NoNewline -ForegroundColor White "4 GB "
        Write-Host -NoNewline -ForegroundColor Green "NFS      VM Storage: "
        Write-Host -ForegroundColor White $NFSVMCapacity "GB"

        $nfsCPU = 2
        $nfsMemory = 4
        $nfsStorage = $NFSCapacity
    } else {
        $nfsCPU = 0
        $nfsMemory = 0
        $nfsStorage = 0
    }

    Write-Host -ForegroundColor White "---------------------------------------------"
    Write-Host -NoNewline -ForegroundColor Green "Total CPU: "
    Write-Host -ForegroundColor White ($esxiTotalCPU + $vcsaTotalCPU + $nsxManagerTotalCPU + $nsxEdgeTotalCPU + $nfsCPU)
    Write-Host -NoNewline -ForegroundColor Green "Total Memory: "
    Write-Host -ForegroundColor White ($esxiTotalMemory + $vcsaTotalMemory + $nsxManagerTotalMemory + $nsxEdgeTotalMemory + $nfsMemory) "GB"
    Write-Host -NoNewline -ForegroundColor Green "Total Storage: "
    Write-Host -ForegroundColor White ($esxiTotalStorage + $vcsaTotalStorage + $nsxManagerTotalStorage + $nsxEdgeTotalStorage + $nfsStorage) "GB"

    Write-Host -ForegroundColor Magenta "`nWould you like to proceed with this deployment?`n"
    $answer = Read-Host -Prompt "Do you accept (Y or N)"
    if($answer -ne "Y" -or $answer -ne "y") {
        exit
    }
    Clear-Host
}

#############Stuff Trevor Added ###########################

New-ResourcePool -Location $AVSCluster -Name $AVSResourcePool

###########################################################

if( $deployNFSVM -eq 1 -or $deployNestedESXiVMs -eq 1 -or $deployVCSA -eq 1) {
    My-Logger "Connecting to Management vCenter Server $VIServer ..."
    $viConnection = Connect-VIServer $VIServer -User $VIUsername -Password $VIPassword -WarningAction SilentlyContinue

    $datastore = Get-Datastore -Server $viConnection -Name $AVSDatastore | Select -First 1
    $resourcepool = Get-ResourcePool -Server $viConnection -Name $AVSResourcePool
    $cluster = Get-Cluster -Server $viConnection -Name $AVSCluster
    $datacenter = $cluster | Get-Datacenter
    $vmhost = $cluster | Get-VMHost | Select -First 1
}

if($deployNestedESXiVMs -eq 1) {
    $NestedESXiHostnameToIPs.GetEnumerator() | Sort-Object -Property Value | Foreach-Object {
        $VMName = $_.Key
        $VMIPAddress = $_.Value

        $ovfconfig = Get-OvfConfiguration $NestedESXiApplianceOVA
        $ovfNetworkLabel = ($ovfconfig.NetworkMapping | Get-Member -MemberType Properties).Name
        $ovfconfig.NetworkMapping.$ovfNetworkLabel.value = $NSXSegName
        $ovfconfig.common.guestinfo.hostname.value = $VMName
        $ovfconfig.common.guestinfo.ipaddress.value = $VMIPAddress
        $ovfconfig.common.guestinfo.netmask.value = $NSXSegNetmask
        $ovfconfig.common.guestinfo.gateway.value = $VCSAGateway
        $ovfconfig.common.guestinfo.dns.value = $NestedClusterDNS
        $ovfconfig.common.guestinfo.domain.value = $VCSASSODomainName
        $ovfconfig.common.guestinfo.ntp.value = $nestedntp
        $ovfconfig.common.guestinfo.syslog.value = $VMSyslog
        $ovfconfig.common.guestinfo.password.value = $adminpassword
        if($nestedssh -eq "true") {
            $nestedsshVar = $true
        } else {
            $nestedsshVar = $false
        }
        $ovfconfig.common.guestinfo.ssh.value = $nestedsshVar

        My-Logger "Deploying Nested ESXi VM $VMName ..."
        $vm = Import-VApp -Source $NestedESXiApplianceOVA -OvfConfiguration $ovfconfig -Name $VMName -Location $resourcepool -VMHost $vmhost -Datastore $datastore -DiskStorageFormat thin -Force
        
        My-Logger "Adding vmnic2/vmnic3 to $NSXSegName ..."
        New-NetworkAdapter -VM $vm -Type Vmxnet3 -NetworkName $NSXSegName -StartConnected -confirm:$false | Out-File -Append -LiteralPath $verboseLogFile
        New-NetworkAdapter -VM $vm -Type Vmxnet3 -NetworkName $NSXSegName -StartConnected -confirm:$false | Out-File -Append -LiteralPath $verboseLogFile

        My-Logger "Updating vCPU Count to $NestedESXivCPU & vMEM to $NestedESXivMEM GB ..."
        Set-VM -Server $viConnection -VM $vm -NumCpu $NestedESXivCPU -MemoryGB $NestedESXivMEM -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile

        if($supportedStorageType.$SddcProvider -eq "VSAN") {
            My-Logger "Updating vSAN Cache VMDK size to $NestedESXiCachingvDisk GB & Capacity VMDK size to $NestedESXiCapacityvDisk GB ..."
            Get-HardDisk -Server $viConnection -VM $vm -Name "Hard disk 2" | Set-HardDisk -CapacityGB $NestedESXiCachingvDisk -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile
            Get-HardDisk -Server $viConnection -VM $vm -Name "Hard disk 3" | Set-HardDisk -CapacityGB $NestedESXiCapacityvDisk -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile
        }

        My-Logger "Powering On $vmname ..."
        $vm | Start-Vm -RunAsync | Out-Null
    }
}

if($deployNFSVM -eq 1 -and $supportedStorageType.$SddcProvider -eq "NFS") {
    $ovfconfig = Get-OvfConfiguration $PhotonNFSOVA
    $ovfNetworkLabel = ($ovfconfig.NetworkMapping | Get-Member -MemberType Properties).Name
    $ovfconfig.NetworkMapping.$ovfNetworkLabel.value = $NSXSegName

    $ovfconfig.common.guestinfo.hostname.value = $NFSVMHostname
    $ovfconfig.common.guestinfo.ipaddress.value = $NFSVMIPAddress
    $ovfconfig.common.guestinfo.netmask.value = $NFSVMPrefix
    $ovfconfig.common.guestinfo.gateway.value = $VCSAGateway
    $ovfconfig.common.guestinfo.dns.value = $NestedClusterDNS
    $ovfconfig.common.guestinfo.domain.value = $VCSASSODomainName
    $ovfconfig.common.guestinfo.root_password.value = $NFSVMRootPassword
    $ovfconfig.common.guestinfo.nfs_volume_name.value = $NFSVMVolumeLabel
    $ovfconfig.Common.disk2size.value = $NFSVMCapacity

    My-Logger "Deploying PhotonOS NFS VM $NFSVMDisplayName ..."
    $vm = Import-VApp -Source $PhotonNFSOVA -OvfConfiguration $ovfconfig -Name $NFSVMDisplayName -Location $resourcepool -VMHost $vmhost -Datastore $datastore -DiskStorageFormat thin -Force

    My-Logger "Powering On $NFSVMDisplayName ..."
    $vm | Start-Vm -RunAsync | Out-Null
}

if($deployVCSA -eq 1) {
        if($IsWindows) {
            $config = (Get-Content -Raw "$($VCSAInstallerPath)\vcsa-cli-installer\templates\install\embedded_vCSA_on_VC.json") | convertfrom-json
        } else {
            $config = (Get-Content -Raw "$($VCSAInstallerPath)/vcsa-cli-installer/templates/install/embedded_vCSA_on_VC.json") | convertfrom-json
        }

        $config.'new_vcsa'.vc.hostname = $VIServer
        $config.'new_vcsa'.vc.username = $VIUsername
        $config.'new_vcsa'.vc.password = $VIPassword
        $config.'new_vcsa'.vc.deployment_network = $NSXSegName
        $config.'new_vcsa'.vc.datastore = $datastore
        $config.'new_vcsa'.vc.datacenter = $datacenter.name
        $config.'new_vcsa'.appliance.thin_disk_mode = $true
        $config.'new_vcsa'.appliance.deployment_option = $VCSADeploymentSize
        $config.'new_vcsa'.appliance.name = $VCSADisplayName
        $config.'new_vcsa'.network.ip_family = "ipv4"
        $config.'new_vcsa'.network.mode = "static"
        $config.'new_vcsa'.network.ip = $VCSAIPAddress
        $config.'new_vcsa'.network.dns_servers[0] = $NestedClusterDNS
        $config.'new_vcsa'.network.prefix = $VCSAPrefix
        $config.'new_vcsa'.network.gateway = $VCSAGateway
        $config.'new_vcsa'.os.ntp_servers = $nestedntp
        $config.'new_vcsa'.network.system_name = $VCSAIPAddress
        $config.'new_vcsa'.os.password = $adminpassword
        if($nestedssh -eq "true") {
            $nestedsshVar = $true
        } else {
            $nestedsshVar = $false
        }
        $config.'new_vcsa'.os.ssh_enable = $nestedsshVar
        $config.'new_vcsa'.sso.password = $adminpassword
        $config.'new_vcsa'.sso.domain_name = $VCSASSODomainName

        # Hack due to JSON depth issue
        $config.'new_vcsa'.vc.psobject.Properties.Remove("target")
        $config.'new_vcsa'.vc | Add-Member NoteProperty -Name target -Value "REPLACE-ME"

        if($IsWindows) {
            My-Logger "Creating VCSA JSON Configuration file for deployment ..."
            $config | ConvertTo-Json | Set-Content -Path "$($ENV:Temp)\jsontemplate.json"
            $target = "[`"$AVSCluster`",`"Resources`",`"$AVSResourcePool`"]"
            (Get-Content -path "$($ENV:Temp)\jsontemplate.json" -Raw) -replace '"REPLACE-ME"',$target | Set-Content -path "$($ENV:Temp)\jsontemplate.json"

            My-Logger "Deploying the VCSA ..."
            Invoke-Expression "$($VCSAInstallerPath)\vcsa-cli-installer\win32\vcsa-deploy.exe install --no-ssl-certificate-verification --accept-eula --acknowledge-ceip $($ENV:Temp)\jsontemplate.json"| Out-File -Append -LiteralPath $verboseLogFile
        } elseif($IsMacOS) {
            My-Logger "Creating VCSA JSON Configuration file for deployment ..."
            $config | ConvertTo-Json | Set-Content -Path "$($ENV:TMPDIR)jsontemplate.json"

            My-Logger "Deploying the VCSA ..."
            Invoke-Expression "$($VCSAInstallerPath)/vcsa-cli-installer/mac/vcsa-deploy install --no-ssl-certificate-verification --accept-eula --acknowledge-ceip $($ENV:TMPDIR)jsontemplate.json"| Out-File -Append -LiteralPath $verboseLogFile
        } elseif ($IsLinux) {
            My-Logger "Creating VCSA JSON Configuration file for deployment ..."
            $config | ConvertTo-Json | Set-Content -Path "/tmp/jsontemplate.json"

            My-Logger "Deploying the VCSA ..."
            Invoke-Expression "$($VCSAInstallerPath)/vcsa-cli-installer/lin64/vcsa-deploy install --no-ssl-certificate-verification --accept-eula --acknowledge-ceip /tmp/jsontemplate.json"| Out-File -Append -LiteralPath $verboseLogFile
        }
}

if($moveVMsIntovApp -eq 1) {
    My-Logger "Creating vApp $VAppName ..."
    $VApp = New-VApp -Name $VAppName -Server $viConnection -Location $resourcepool

    if(-Not (Get-Folder $VMFolder -ErrorAction Ignore)) {
        My-Logger "Creating VM Folder $VMFolder ..."
        $folder = New-Folder -Name $VMFolder -Server $viConnection -Location (Get-Datacenter $AVSDatacenter | Get-Folder vm)
    }

    if($deployNFSVM -eq 1 -and $supportedStorageType.$SddcProvider -eq "NFS") {
        $vcsaVM = Get-VM -Name $NFSVMDisplayName -Server $viConnection
        My-Logger "Moving $NFSVMDisplayName into $VAppName vApp ..."
        Move-VM -VM $vcsaVM -Server $viConnection -Destination $VApp -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile
    }

    if($deployNestedESXiVMs -eq 1) {
        My-Logger "Moving Nested ESXi VMs into $VAppName vApp ..."
        $NestedESXiHostnameToIPs.GetEnumerator() | Sort-Object -Property Value | Foreach-Object {
            $vm = Get-VM -Name $_.Key -Server $viConnection
            Move-VM -VM $vm -Server $viConnection -Destination $VApp -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile
        }
    }

    if($deployVCSA -eq 1) {
        $vcsaVM = Get-VM -Name $VCSADisplayName -Server $viConnection
        My-Logger "Moving $VCSADisplayName into $VAppName vApp ..."
        Move-VM -VM $vcsaVM -Server $viConnection -Destination $VApp -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile
    }

    My-Logger "Moving $VAppName to VM Folder $VMFolder ..."
    Move-VApp -Server $viConnection $VAppName -Destination (Get-Folder -Server $viConnection $VMFolder) | Out-File -Append -LiteralPath $verboseLogFile
}

if( $deployNFSVM -eq 1 -or $deployNestedESXiVMs -eq 1 -or $deployVCSA -eq 1) {
    My-Logger "Disconnecting from $VIServer ..."
    Disconnect-VIServer -Server $viConnection -Confirm:$false
}

if($setupNewVC -eq 1) {
    My-Logger "Connecting to the new VCSA ..."
    $vc = Connect-VIServer $VCSAIPAddress -User "administrator@$VCSASSODomainName" -Password $adminpassword -WarningAction SilentlyContinue -Force

    $d = Get-Datacenter -Server $vc $NewVCDatacenterName -ErrorAction Ignore
    if( -Not $d) {
        My-Logger "Creating Datacenter $NewVCDatacenterName ..."
        New-Datacenter -Server $vc -Name $NewVCDatacenterName -Location (Get-Folder -Type Datacenter -Server $vc) | Out-File -Append -LiteralPath $verboseLogFile
    }

    $c = Get-Cluster -Server $vc $NewVCVSANClusterName -ErrorAction Ignore
    if( -Not $c) {
        if($configureESXiStorage -eq 1 -and $supportedStorageType.$SddcProvider -eq "VSAN") {
            My-Logger "Creating VSAN Cluster $NewVCVSANClusterName ..."
            New-Cluster -Server $vc -Name $NewVCVSANClusterName -Location (Get-Datacenter -Name $NewVCDatacenterName -Server $vc) -DrsEnabled -VsanEnabled | Out-File -Append -LiteralPath $verboseLogFile
        } else {
            My-Logger "Creating vSphere Cluster $NewVCVSANClusterName ..."
            New-Cluster -Server $vc -Name $NewVCVSANClusterName -Location (Get-Datacenter -Name $NewVCDatacenterName -Server $vc) -DrsEnabled | Out-File -Append -LiteralPath $verboseLogFile
        }
    }

    if($addESXiHostsToVC -eq 1) {
        $NestedESXiHostnameToIPs.GetEnumerator() | Sort-Object -Property Value | Foreach-Object {
            $VMName = $_.Key
            $VMIPAddress = $_.Value

            $targetVMHost = $VMIPAddress
            if($addHostByDnsName -eq 1) {
                $targetVMHost = $VMName
            }
            My-Logger "Adding ESXi host $targetVMHost to Cluster ..."
            Add-VMHost -Server $vc -Location (Get-Cluster -Name $NewVCVSANClusterName) -User "root" -Password $adminpassword -Name $targetVMHost -Force | Out-File -Append -LiteralPath $verboseLogFile
        }
    }

    if($configureESXiStorage -eq 1) {
        if($supportedStorageType.$SddcProvider -eq "VSAN") {
            My-Logger "Enabling VSAN & disabling VSAN Health Check ..."
            Get-VsanClusterConfiguration -Server $vc -Cluster $NewVCVSANClusterName | Set-VsanClusterConfiguration -HealthCheckIntervalMinutes 0 | Out-File -Append -LiteralPath $verboseLogFile

            foreach ($vmhost in Get-Cluster -Server $vc | Get-VMHost) {
                $luns = $vmhost | Get-ScsiLun | select CanonicalName, CapacityGB

                My-Logger "Querying ESXi host disks to create VSAN Diskgroups ..."
                foreach ($lun in $luns) {
                    if(([int]($lun.CapacityGB)).toString() -eq "$NestedESXiCachingvDisk") {
                        $vsanCacheDisk = $lun.CanonicalName
                    }
                    if(([int]($lun.CapacityGB)).toString() -eq "$NestedESXiCapacityvDisk") {
                        $vsanCapacityDisk = $lun.CanonicalName
                    }
                }
                My-Logger "Creating VSAN DiskGroup for $vmhost ..."
                New-VsanDiskGroup -Server $vc -VMHost $vmhost -SsdCanonicalName $vsanCacheDisk -DataDiskCanonicalName $vsanCapacityDisk | Out-File -Append -LiteralPath $verboseLogFile
            }
        } else {
            My-Logger "Adding NFS Storage ..."
            foreach ($vmhost in Get-Cluster -Server $vc | Get-VMHost) {
                $vmhost | New-Datastore -Nfs -Name $NFSVMVolumeLabel -Path /mnt/${NFSVMVolumeLabel} -NfsHost $NFSVMIPAddress | Out-File -Append -LiteralPath $verboseLogFile
            }
        }
    }

    if($configureVDS -eq 1) {
        $vds = New-VDSwitch -Server $vc  -Name $NewVCVDSName -Location (Get-Datacenter -Name $NewVCDatacenterName) -Mtu 1600

      #  New-VDPortgroup -Server $vc -Name $NewVCMgmtDVPGName -Vds $vds | Out-File -Append -LiteralPath $verboseLogFile
        New-VDPortgroup -Server $vc -Name $NewVCWorkloadDVPGName -Vds $vds | Out-File -Append -LiteralPath $verboseLogFile

        foreach ($vmhost in Get-Cluster -Server $vc | Get-VMHost) {
            My-Logger "Adding $vmhost to $NewVCVDSName"
            $vds | Add-VDSwitchVMHost -VMHost $vmhost | Out-Null

            $vmhostNetworkAdapter = Get-VMHost $vmhost | Get-VMHostNetworkAdapter -Physical -Name vmnic1
            $vds | Add-VDSwitchPhysicalNetworkAdapter -VMHostNetworkAdapter $vmhostNetworkAdapter -Confirm:$false
        }
    }

    if($clearHealthCheckAlarm -eq 1 -and $supportedStorageType.$SddcProvider -eq "VSAN") {
        My-Logger "Clearing Health Check Alarms ..."
        $alarmMgr = Get-View AlarmManager -Server $vc
        Get-Cluster -Server $vc | where {$_.ExtensionData.TriggeredAlarmState} | %{
            $cluster = $_
            $Cluster.ExtensionData.TriggeredAlarmState | %{
                $alarmMgr.AcknowledgeAlarm($_.Alarm,$cluster.ExtensionData.MoRef)
            }
        }
        $alarmSpec = New-Object VMware.Vim.AlarmFilterSpec
        $alarmMgr.ClearTriggeredAlarms($alarmSpec)
    }

    # Final configure and then exit maintanence mode in case patching was done earlier
    foreach ($vmhost in Get-Cluster -Server $vc | Get-VMHost) {
        # Disable Core Dump Warning
        Get-AdvancedSetting -Entity $vmhost -Name UserVars.SuppressCoredumpWarning | Set-AdvancedSetting -Value 1 -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile

        # Enable vMotion traffic
        $vmhost | Get-VMHostNetworkAdapter -VMKernel | Set-VMHostNetworkAdapter -VMotionEnabled $true -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile

        if($vmhost.ConnectionState -eq "Maintenance") {
            Set-VMHost -VMhost $vmhost -State Connected -RunAsync -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile
        }
    }

    if($deployWorkload -eq 1) {
        $vmhost = Get-Cluster -Server $vc | Get-VMHost | Select -First 1
        $datastore = Get-Datastore -Server $vc

        $ovfconfig = Get-OvfConfiguration -Server $vc $PhotonOSOVA
        $ovfNetworkLabel = ($ovfconfig.NetworkMapping | Get-Member -MemberType Properties).Name
        $ovfconfig.NetworkMapping.$ovfNetworkLabel.value = $NewVCWorkloadDVPGName

        foreach ($i in 1..$NewVcWorkloadVMCount) {
            $VMName = "$NewVCWorkloadVMFormat$i"
            $vm = Import-VApp -Server $vc -Source $PhotonOSOVA -OvfConfiguration $ovfconfig -Name $VMName -VMHost $VMhost -Datastore $Datastore -DiskStorageFormat thin -Force
            $vm | Start-VM -Server $vc -Confirm:$false | Out-Null
        }
    }

    My-Logger "Disconnecting from new VCSA ..."
    Disconnect-VIServer $vc -Confirm:$false
}

$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

My-Logger "Nested SDDC Lab Deployment Complete!"
My-Logger "StartTime: $StartTime"
My-Logger "  EndTime: $EndTime"
My-Logger " Duration: $duration minutes"
