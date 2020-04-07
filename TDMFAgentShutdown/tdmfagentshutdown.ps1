# TDMF Agents Online
# Example Partition Input "System Reserved:;Windows:"
# Example "G:;H:"

param([string]$inputdrives)

write-host $inputdrives

function tdmfagentshutdown ($inputdrives){

    $drives = $inputdrives.split(";")

    Write-host "Drive Letter :" $drives[0] "= Partition: " (Get-Volume -DriveLetter $drives[0][0]).FileSystemLabel
    Write-host "Drive Letter :" $drives[0] "= Partition Active Status: " (Get-Partition -DriveLetter $drives[0][0]).IsActive
    Write-host "Drive Letter :" $drives[1] "= Partition: " (Get-Volume -DriveLetter $drives[1][0]).FileSystemLabel

    if (((((Get-Volume -DriveLetter $drives[0][0]).FileSystemLabel -eq "System Reserved") -and ((Get-Volume -DriveLetter $drives[1][0]).FileSystemLabel -eq "Windows")) -ne $true) -or ((Get-Partition -DriveLetter $drives[0][0]).IsActive) -ne $true){
        write-host "Error: The input 'System Reserved' and 'Windows' Partitions do not match OR 'System Reserved' Partition is not Active"
        return
    }

    $destdrive = $drives[1]
        
    $regvalue="$destdrive"+"Windows\System32\config\SYSTEM"
    reg load HKLM\AzureTempSystem $regvalue
    reg add "HKLM\AzureTempSystem\ControlSet001\services\Dtc_ReplServer" /v Start /t REG_DWORD /d 4 /f
    $logfilename = "TDMF" +"_" + "Drives" + "_" + $drives[0][0] + "_" + $drives[1][0]
    Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\AzureTempSystem\ControlSet001\services\Dtc_ReplServer | Out-File C:\Log\$logfilename.log
    [gc]::Collect()
    reg unload HKLM\AzureTempSystem
}

tdmfagentshutdown($inputdrives)

