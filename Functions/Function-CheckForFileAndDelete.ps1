#checkforfileanddelete function

function checkfileanddelete {

    param (
        $filetodelete 
    )
    $test = Test-Path -Path $filetodelete
    
    if ($test -eq "True"){
    Remove-Item $filetodelete -Force
    $test = Test-Path -Path $filetodelete

    If ("True" -eq $test){Write-Host -ForegroundColor Red "Could not delete file $filetodelete"
    Exit}

    If ("False" -eq $test){Write-Host -ForegroundColor Green "Successfully deleted $filetodelete"}


    }

    }