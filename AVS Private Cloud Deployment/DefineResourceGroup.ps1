$regionfordeployment = "Southeast Asia"
$RGNewOrExisting = "New"

if ( "Existing" -eq $RGNewOrExisting )
{
    $AVSRG = "MyTestRG-deleteme"

    write-host -foregroundcolor Green = "
AVS Private Cloud Resource Group is $AVSRG
"
}

if ( "New" -eq $RGNewOrExisting){
    $AVSRG = "AVS RG Name"
    New-AzResourceGroup -Name $AVSRG -Location $regionfordeployment

    write-host -foregroundcolor Green = "
Success: AVS Private Cloud Resource Group $AVSRG Created
"
    

}

write-host $sub