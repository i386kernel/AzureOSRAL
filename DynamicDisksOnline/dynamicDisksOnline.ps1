# Dynamic Disks Online
# Example Partition Input "System Reserved:;Windows:"
# Example "G:;H:"

param([string]$inputdrives)

write-host $inputdrives
function dynamicdisksonline ($inputdrives){

    $drives = $inputdrives.split(";")

    Write-host "Drive Letter :" $drives[0] "= Partition: " (Get-Volume -DriveLetter $drives[0][0]).FileSystemLabel
    Write-host "Drive Letter :" $drives[0] "= Partition Active Status: " (Get-Partition -DriveLetter $drives[0][0]).IsActive
    Write-host "Drive Letter :" $drives[1] "= Partition: " (Get-Volume -DriveLetter $drives[1][0]).FileSystemLabel

    if (((((Get-Volume -DriveLetter $drives[0][0]).FileSystemLabel -eq "System Reserved") -and ((Get-Volume -DriveLetter $drives[1][0]).FileSystemLabel -eq "Windows")) -ne $true) -or ((Get-Partition -DriveLetter $drives[0][0]).IsActive) -ne $true){
        write-host "Error: The input 'System Reserved' and 'Windows' Partitions do not match OR 'System Reserved' Partition is not Active"
        return
    }
    $destdrive = $drives[1]

    $path = "$destdrive\Windows\System32\GroupPolicy\Machine\Scripts\Startup"
    $eamsroot="C:\bootrec"

    $regvalue="$destdrive"+"Windows\System32\config\SOFTWARE"
    reg load HKLM\AzureTempSoftware $regvalue

    if (-not (Test-Path $path)) {
        $handle = New-Item -path $path -itemType Directory
        $handle.Handle.Close()
        Start-Sleep -s 2
    }
    Copy-Item $eamsroot\dynamicdisk.ps1 $path
    Start-Sleep -s 2
    'HKLM:\AzureTempSoftware\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Startup\0',
    'HKLM:\AzureTempSoftware\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Startup\0' |
    ForEach-Object {

        if (Test-Path Registry::$_){
            Write-Host "Path and Item Already exists"
        }else { 
            New-Item -path $_ -force
            New-ItemProperty -path "$_" -name DisplayName -propertyType String -value "Local Group Policy" 
            New-ItemProperty -path "$_" -name FileSysPath -propertyType String -value "$destdrive\windows\System32\GroupPolicy\Machine" 
            New-ItemProperty -path "$_" -name GPO-ID -propertyType String -value "LocalGPO"
            New-ItemProperty -path "$_" -name GPOName -propertyType String -value "Local Group Policy"
            New-ItemProperty -path "$_" -name PSScriptOrder -propertyType DWord -value 2 
            New-ItemProperty -path "$_" -name SOM-ID -propertyType String -value "Local"
        }    
    }
    'HKLM:\AzureTempSoftware\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Startup\0\0',
    'HKLM:\AzureTempSoftware\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Startup\0\0' |
    ForEach-Object {
        
        if (Test-Path Registry::$_){
            Write-Host "Path and Item Already exists"
        }else {
            New-Item -path $_ -force 
            New-ItemProperty -path "$_" -name Script -propertyType String -value 'dynamicdisk.ps1'
            New-ItemProperty -path "$_" -name Parameters -propertyType String -value ''
            New-ItemProperty -path "$_" -name IsPowershell -propertyType DWord -value 1
            New-ItemProperty -path "$_" -name ExecTime -propertyType QWord -value 0
        }
    }
    $logfilename = "Dynamic_Disks" +"_" + "Drives" + "_" + $drives[0][0] + "_" + $drives[1][0]

    Start-Sleep -s 2
    Get-Item -Path Registry::"HKEY_LOCAL_MACHINE\AzureTempSoftware\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Startup\0" | Out-File C:\Log\$logfilename.log
    Get-Item -Path Registry::"HKEY_LOCAL_MACHINE\AzureTempSoftware\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Startup\0" >> C:\Log\$logfilename.log
    Get-Item -Path Registry::"HKEY_LOCAL_MACHINE\AzureTempSoftware\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Startup\0\0" >> C:\Log\$logfilename.log
    Get-Item -Path Registry::"HKEY_LOCAL_MACHINE\AzureTempSoftware\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Startup\0\0" >> C:\Log\$logfilename.log
    Start-Sleep -s 2

    [gc]::Collect()
    reg unload HKLM\AzureTempSoftware
}

dynamicdisksonline($inputdrives)