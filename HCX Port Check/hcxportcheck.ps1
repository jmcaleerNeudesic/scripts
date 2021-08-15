write-host "This should be run from an on-premises network.  

This script tests connectivity to the AVS vCenter, NSX Manager and HCX Manager from the network it is run from.

You will need the IP of the AVS vCenter, NSX Manager and HCX Manager, if you don't already have those go and collect them."

$start = read-host -Prompt "
Would you like to begin? (Y/N)"

if ('y' -eq $start) {
    $vcenterip = Read-Host -Prompt "
    IP Address of AVS vCenter"
    $nsxip = Read-Host -Prompt "
    IP Address of AVS NSX Manager"
    $hcxip = Read-Host -Prompt "  
    IP Address of AVS HCX Manager"
    
    $vcenterporttest = Test-NetConnection -ComputerName $vcenterip -Port 443
    $nsxporttest = Test-NetConnection -ComputerName $nsxip -Port 443
    $hcxporttest = Test-NetConnection -ComputerName $hcxip -Port 443

    $vcentertcpresult = $vcenterporttest.TcpTestSucceeded
    if ('False' -eq $vcentertcpresult) {
        $resultcolor = "Red"
        $result = "Connection Failed"}
    if ('True' -eq $vcentertcpresult){
        $resultcolor = "Green"
        $result = "Connection Succeeded"}
    Write-Host -NoNewline -ForegroundColor White "vCenter ($vcenterip): " 
    Write-Host -ForegroundColor $resultcolor "$result"

    $nsxtcpresult = $nsxporttest.TcpTestSucceeded
    if ('False' -eq $nsxtcpresult) {
        $resultcolor = "Red"
        $result = "Connection Failed"}
    if ('True' -eq $nsxtcpresult){
        $resultcolor = "Green"
        $result = "Connection Succeeded"}
    Write-Host -NoNewline -ForegroundColor White "NSX Manager ($nsxip): " 
    Write-Host -ForegroundColor $resultcolor "$result"

    $hcxtcpresult = $hcxporttest.TcpTestSucceeded
    if ('False' -eq $hcxtcpresult) {
        $resultcolor = "Red"
        $result = "Connection Failed"}
    if ('True' -eq $hcxtcpresult){
        $resultcolor = "Green"
        $result = "Connection Succeeded"}
    Write-Host -NoNewline -ForegroundColor White "HCX Manager ($hcxip): " 
    Write-Host -ForegroundColor $resultcolor "$result"
}

else {
    Exit-PSHostProcess
}