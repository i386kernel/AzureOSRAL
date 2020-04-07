# Fix MBR
# Example Partition Input "System Reserved:;Windows:"
# Example "G:;H:"

param([string]$inputdrives)

write-host $inputdrives

function writeMBR ($inputdrives){

    $drives = $inputdrives.split(";")
  
    Write-host "Drive Letter :" $drives[0] "= Partition: " (Get-Volume -DriveLetter $drives[0][0]).FileSystemLabel
    Write-host "Drive Letter :" $drives[0] "= Partition Active Status: " (Get-Partition -DriveLetter $drives[0][0]).IsActive
    Write-host "Drive Letter :" $drives[1] "= Partition: " (Get-Volume -DriveLetter $drives[1][0]).FileSystemLabel

    if (((((Get-Volume -DriveLetter $drives[0][0]).FileSystemLabel -eq "System Reserved") -and ((Get-Volume -DriveLetter $drives[1][0]).FileSystemLabel -eq "Windows")) -ne $true) -or ((Get-Partition -DriveLetter $drives[0][0]).IsActive) -ne $true){
        write-host "Error: The input 'System Reserved' and 'Windows' Partitions do not match OR 'System Reserved' Partition is not Active"
        return
    }
  
    $bootdrive = $drives[0]
    $destdrive = $drives[1]

    Write-Host "Boot Drive": $bootdrive, "Dest Drive": $destdrive

    $bcdedit="$destdrive"+"\windows\system32\bcdedit.exe"
    
    NEW-ITEM -Force -path "C:\TEMP" -name bcbootmbr.bat -ItemType File
    
    $bcdfile = "C:\TEMP\bcbootmbr.bat"
    $bcdlog = "C:\TEMP\bcbootmgr.log"

    ADD-CONTENT -Path "C:\TEMP\bcbootmbr.bat" "$bcdedit /store $bootdrive\\boot\\BCD /set {default} osdevice partition=$destdrive"
    ADD-CONTENT -Path "C:\TEMP\bcbootmbr.bat" "$bcdedit /store $bootdrive\\boot\\BCD /set {default} device partition=$destdrive"
    ADD-CONTENT -Path "C:\TEMP\bcbootmbr.bat" "$bcdedit /store $bootdrive\\boot\\BCD /set {bootmgr} device partition=$bootdrive"
   
    $logfilename = "FixMBR" +"_" + "Drives" + "_" + $drives[0][0] + "_" + $drives[1][0]

    C:\TEMP\bcbootmbr.bat | Out-File C:\Log\$logfilename.log
    
    "/store $drives[0][0]:\Boot\bcd" | bcdedit.exe | Add-Content C:\Log\$logfilename.log

    if (Test-Path $bcdfile) {
    Remove-Item -Path $bcdfile |Out-Null
    }
    
    if (Test-Path $bcdlog) {
    Remove-Item -Path $bcdlog |Out-Null
    }
}
writeMBR ($inputdrives)
