param([string]$inputdrives)

write-host "Input Drives: " $inputdrives

function activatepartition ($inputdrives){

    $drives = $inputdrives.split(";")
    Write-host "Drive Letter :" $drives[0] "= Partition: " (Get-Volume -DriveLetter $drives[0][0]).FileSystemLabel
    Write-host "Drive Letter :" $drives[0] "= Initial Partition Active Status: " (Get-Partition -DriveLetter $drives[0][0]).IsActive
    Write-host "Drive Letter :" $drives[1] "= Partition: " (Get-Volume -DriveLetter $drives[1][0]).FileSystemLabel

    if ((((Get-Volume -DriveLetter $drives[0][0]).FileSystemLabel -eq "System Reserved") -and ((Get-Volume -DriveLetter $drives[1][0]).FileSystemLabel -eq "Windows")) -ne $true){
        write-Error "Error: The input System Reserved and Windows Partition do not match."
        return
    }
    set-partition -Driveletter $drives[0][0] -isactive $true
    write-host "Final Activation Status of Drive - " $drives[0] (Get-Partition -DriveLetter $drives[0][0]).IsActive
    $logfilename = "ActivateSysPartition" +"_" + "Drives" + "_" + $drives[0][0] + "_" + $drives[1][0]
    if(-Not(Test-Path C:\Log)){
        New-Item -ItemType directory -Path C:\Log
    }

    "System Reserved Partition = " + $drives[0] + " Final Activation Status : " + (Get-Partition -DriveLetter $drives[0][0]).IsActive | Out-File C:\Log\$logfilename.log
}

activatepartition($inputdrives)