
$path = "e:\Taxes"


$fetchedDirList = Get-ChildItem $path -directory -recurse
$emptyDirectoryList = $fetchedDirList | Where-Object { (Get-ChildItem $_.fullName).count -eq 0 }
$finalListToRemove = $emptyDirectoryList | Select-Object -expandproperty FullName

If($finalListToRemove.count -eq 0){
Write-Host -Foregroundcolor Green "No Empty Folders"
}

if ($finalListToRemove.count -gt 0) {
    <# Action to perform if the condition is true #>

    $finalListToRemove

    Write-Host -ForegroundColor Yellow "Do you want to delete the directories above? (Y/N)"
    $response = Read-Host
    
    if ($response -eq "Y"){
    do{
    $fetchedDirList = Get-ChildItem $path -directory -recurse
    $emptyDirectoryList = $fetchedDirList | Where-Object { (Get-ChildItem $_.fullName).count -eq 0 }
    $finalListToRemove = $emptyDirectoryList | Select-Object -expandproperty FullName
    $finalListToRemove | Foreach-Object { Remove-Item $_ }
    } while ( $finalListToRemove.count -gt 0 )
    }
}

