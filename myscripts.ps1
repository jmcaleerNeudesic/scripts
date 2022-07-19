###############################
#Azure Login Function
###############################

$filename = "azurelogin-function.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/AzureScripts/main/Functions/$filename" -OutFile $env:TEMP\AVSDeploy\$filename
. $env:TEMP\AVSDeploy\$filename

#######################################################################################
#FUNCTIONS
#######################################################################################
$progressPreference = 'silentlyContinue'

$buildhol_ps1 = "Yes"
$avsdeploy_ps1 = "Yes"
$filelistarray = @()
$filelistarray += $buildhol_ps1, $avsdeploy_ps1
$filelistarray
$skipvariables = $filelistarray





if ($buildhol_ps1 -notmatch "Yes" -and $avsdeploy_ps1 -notmatch "Yes"

$array = @("azureloginfunction.ps1", "checkavsvcentercommunicationfunction.ps1", "getfilesizefunction.ps1") 
foreach ($filename in $array){ 
  Write-Host "Downloading $filename"
  Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVSSimplifiedDeployment/$filename" -OutFile $env:TEMP\AVSDeploy\$filename
  . $env:TEMP\AVSDeploy\$filename
}





, "checkavsvcentercommunicationfunction.ps1", "getfilesizefunction.ps1"

Write-Host "$$filelistarray"

$buildhol_ps1 -notmatch "Yes" -and $avsdeploy_ps1 -notmatch "Yes"


){


