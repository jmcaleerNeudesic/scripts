function createdirectoryandlog {

    param (
        $folder, 
        $foldername,
        $logfilename
    )

    $test = Test-Path -Path $folder\$foldername
    
    if ($test -eq "True"){
Write-Host -ForegroundColor Blue "Folder $folder Already Exists"}

else {

#Create Directory
mkdir $folder\$foldername
}

#Start Logging
Start-Transcript -Path $folder\$logfilename.log -Append
    }



    