package require java
java::import panaces.common.utils.logger
java::import panaces.common.utils.InstallUtil
java::import panaces.agents.generic.GenericKVPvtConfig

# Invoke Public Static methods on Java classes from Tcl code
# Import all the appropriate libraries w.r.t to this TCL Script
set eamsroot [ java::call InstallUtil getRootDir]
source  [file join $eamsroot "lib/agentscommon.tcl"]
source  [file join $eamsroot "lib/TextProcessor.tcl"]
source  [file join $eamsroot "lib/utils.tcl"]
$logger print "EAMSROOT is $eamsroot"
set scriptroot [file join $eamsroot "scripts/repository"]
set PanacesTCL_LibraryPath  [file join $scriptroot "library"]
$PANACES_CLI_ARGS1 setArgs "PanacesTCL_LibraryPath" $PanacesTCL_LibraryPath
set libPath  "$eamsroot/scripts/repository/library"
$logger print "Libpath is $libPath"
source "$libPath/PanaceOperatingSystemTCL.lib"
source "$libPath/PanacesCommonLIB.tcl"

set psScriptroot "C:\\PROGRA~1\\panaces\\DRMAgents\\agents\\AzureWinOS\\FixMBR\\fixMBR.bat"
SetDisplayUI "Fix MBR"
## $logger print "Looking for boot disks to mount $psScriptroot"

#Inialize the variables, arrays
set scriptOut {}
set scriptName [ file join $psScriptroot]
set drives [getKeyValue drives]
set paramList [list $drives]  
set successExitCode 0
set TCL_OUTPUT {}
set executionFailed " Execute the below steps manually "


# Check if parameters are present in parmlist variable, if it is present initialize it to a list
if { [ info exists paramList ] == 0 } {
	set paramList [ list ]
}

# Runscript with arguments passed in paramlist variable with defined timeout set exitCode
set exitCode [ runCommandWithTimeout "$scriptName" $paramList scriptOut 900 0 ]
SetDisplayUI $executionFailed
$logger print "output is $scriptOut"
if {$exitCode == 1} {
	SetDisplayUI "Error in execution - Mount disk unsuccessful $scriptOut"
	error "Execution failed. Error is $scriptOut"
}

# RegEx to check if pattern(Err) exists in string value($scriptOut) see if it's successfully excuted
set searchResult [regexp -nocase "Err" $scriptOut]
if {$searchResult == 1} {
	error "Failed to execute. Error is $scriptOut"
    SetDisplayUI $executionFailed
} else {
    SetDisplayUI "Successfully Excuted; Disk Mounted $scriptOut"
}

$logger print "Mounted Disks!...$scriptOut"
