# ID Boot Disk and Mount
# Example Partition Input "System Reserved:;Windows:"
# Example "G:;H:"

param([string]$drive1, [string]$drive2)

$alldrives = $drive1 + $drive2
function getosvolume ($partitionnames) {

    $drives = $partitionnames.split(";")

    Write-host "Drive Letter :" $drives[0] "= Partition: " (Get-Volume -DriveLetter $drives[0][0]).FileSystemLabel
    Write-host "Drive Letter :" $drives[0] "= Partition Active Status: " (Get-Partition -DriveLetter $drives[0][0]).IsActive
    Write-host "Drive Letter :" $drives[1] "= Partition: " (Get-Volume -DriveLetter $drives[1][0]).FileSystemLabel

    if ((((Get-Volume -DriveLetter $drives[0][0]).FileSystemLabel -eq "System Reserved") -and ((Get-Volume -DriveLetter $drives[1][0]).FileSystemLabel -eq "Windows")) -ne $true){
        write-host "Error: The input System Reserved and Windows Partition do not match Or System Reserved Partition is not Active"
        return
    }
    Write-Host "Getting the disks"
    $partitionname = $partitionnames.split(";")[0][0]
    $mappedvol =""
    # Gets Diskpart output and extracts volume to drive letter mapping; makes approprite volume active
    $volumes = "list volume" | diskpart
    for($i = 0; $i -lt $volumes.count; $i++){
        $indvol = $volumes[$i].split(" ")
        if ($indvol[8] -eq $partitionname){
            write-host "Volume" $indvol[2, 3], "Partition: " $indvol[8]
            $mappedvol = $indvol[3]
            write-host "Mapped volume for your drive" : $mappedvol
            break
        }
    }
    $activatevol = " SELECT VOLUME $mappedvol ", "ACTIVE" | diskpart | Out-File C:\activevol.log
    Write-Host $activatevol
}
getosvolume ($alldrives)
