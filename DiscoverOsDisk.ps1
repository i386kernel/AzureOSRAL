param([string]$diskNumber)

function getSelProps ([Array]$parms){

    $selectedProp = $parms[0]
    $getobj = $parms[1]
    $listproperties = @()

    if ($null -eq $getObj.count){
        $propertyhash0 = @{}
        foreach($i in $selectedProp){
            $propertyhash0.Add($i, $getobj.$i)
        }
        $listproperties += $propertyhash0              
    } else { 
        for($j = 0; $j -lt $getobj.count; $j++){
            $propertyhash1 = @{}
            foreach($i in $selectedProp){
                if ($i -eq 'AccessPaths'){
                    $propertyhash1.Add($i, ([Array]$getobj[$j].$i))
                }else {
                    $propertyhash1.Add($i, ($getobj[$j].$i))
                }
        }
        $listproperties += $propertyhash1
        }
    }
    return $listproperties
}

function selnestVolInPart ([Array]$parms){
   
    # Nest Volume in Partition by mapping Partition AccessPath Property 
    # and Volume Path Property

    $selpropPart = $parms[0]
    $selpropVol = $parms[1]

    $partitionhash = @{}
    $volumehash = @{}
    $partresult = Get-Partition
    $volresult = Get-Volume
    $getPartition = getSelProps($selpropPart, $partresult)
    $getVolume = getSelProps($selpropVol, $volresult)
    $partitionhash.Add('getPartition', [Array]$getPartition)
    $volumehash.Add('getVolume', [Array]$getVolume)
    
    foreach($gp in $partitionhash['getPartition']){
        foreach($gv in $volumehash['getVolume']){
            if($gv['Path'] -in $gp['AccessPaths']){
                $gp.Add('Volumes', [Array]$gv)
            }   
        }
    }
    return $partitionhash
}
function selnestVolandPartInDisk ([Array]$params) {

    # Takes nested Partition-Volume structure and nests it under 
    # appropriate Disk

    $selpropDisk = $params[0]
    $nestedvolparthash = $params[1]

    $diskhash = @{}
    $volresult = Get-Disk
    $getDisk = getSelProps($selpropDisk, $volresult)
    $diskhash.Add("Disks",[Array]$getDisk)
    $partitionArray = @()

    foreach($gd in $diskhash['Disks']){
        $gd.Add('Partitions', $partitionArray)
        foreach($gp in $nestedvolparthash['getPartition']){
            if ($gd['Path'] -eq $gp['DiskID']){
                $gd['Partitions'] += $gp
            }
        }
    }
   return $diskhash
}

$diskprop = @(
            "PartitionStyle",     
            "OperationalStatus",      
            "IsBoot",       
            "IsSystem",   
            "Number"    
            "NumberOfPartitions",   
            "Size",  
            "Path", 
            "Location"    
            )
			
$partitionProp = @(               
            "DiskId",        
            "IsActive",     
            "Size",  
            "IsSystem",   
            "OperationalStatus",       
            "Type",
            "AccessPaths",
            "PartitionNumber",
			"DiskNumber"			
            )
			
$volumeProp = @(           
            "FileSystemType",  
            "DriveLetter",
            "FileSystem",
            "FileSystemLabel", 
            "Path", 
            "Size"  
            )

function getSingleDisk{
    
    $nestedvolinpart = selnestVolInPart($partitionProp, $volumeProp)
    $selfullstructure = selnestVolandPartInDisk($diskprop, $nestedvolinpart)
    $diskint = $diskNumber -as [int]
    foreach($disk in $selfullstructure['Disks']){
        if ($disk['Number'] -eq $diskint){
            return $disk
        }
    }
}

function getAll{
    if ($diskNumber -eq ""){        
        $nestedvolinpart = selnestVolInPart($partitionProp, $volumeProp)
        $selfullstructure = selnestVolandPartInDisk($diskprop, $nestedvolinpart)
        ConvertTo-Json $selfullstructure -Depth 50 
    } else {
        $inddisk = getSingleDisk
        ConvertTo-Json $inddisk -Depth 50 
    }
}

getAll
