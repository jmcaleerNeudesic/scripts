$vcenterip = Read-Host -Prompt "
IP Address of AVS vCenter: "
$nsxip = Read-Host -Prompt "
IP Address of AVS NSX Manager: "
$hcxip = Read-Host -Prompt "  
IP Address of AVS HCX Manager: "

$vcenterporttest = Test-NetConnection -ComputerName $vcenterip -Port 445

