
Function BringDynamicDisksOnline{
    foreach($eachdisk in Get-Disk) {
            if($eachdisk.Operationalstatus -eq "offline"){
                Set-Disk -Number $eachdisk.number -IsOffline $False
            }
    }
}

BringDynamicDisksOnline

