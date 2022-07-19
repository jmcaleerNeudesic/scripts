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