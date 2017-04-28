<#
.Synopsis
   Patch WebLogic and Java
.DESCRIPTION
   This script will:
   1. Create a tarball from the current JAVA_HOME
   2. Create a tarball from the current WebLogic ORACLE_HOME
.EXAMPLE
   .\createCPUTarballs.ps1 -jdk_version 1.7.0_141 -wl_version 12.1.3.0.170418
.INPUTS
    JDK Version to deploy
    WebLogic Version to Deploy
    Current PeopleTools version 
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]$jdk_version,
    [Parameter(Mandatory=$true)]$wl_version
)

$env:ARCHIVE_HOME   = "c:\vagrant\dpk\archives"
$env:ORACLE_HOME    = $(hiera weblogic_location)
$env:JAVA_HOME      = $(hiera jdk_location)
$random = get-random
$TEMP = "${env:TEMP}\${random}"
$startDTM = (Get-Date)
$computername = (Get-WmiObject Win32_Computersystem).Name.toLower()

# ---------------------------------------------------------------------------------------------------------------------

###############################
## Java
###############################

Write-Host "`t[${computername}] [Task] Create Java Tarball"
7z a -ttar "${TEMP}\pt-jdk${jdk_version}.tar" $env:JAVA_HOME\*
7z a -tgzip "${env:ARCHIVE_HOME}\pt-jdk${jdk_version}.tgz" "${TEMP}\pt-jdk${jdk_version}.tar"
Write-Host "`t[${computername}] [Done] Create Java Tarball"

###############################
## WebLogic
###############################

Write-Host "`t[${computername}] [Task] Create WebLogic Tarball"
. ${env:ORACLE_HOME}\oracle_common\bin\copyBinary.cmd -javaHome ${env:JAVA_HOME} -archiveLoc ${TEMP}\pt-weblogic-copy.jar -sourceMWHomeLoc ${env:ORACLE_HOME}

7z a -ttar "${TEMP}\pt-weblogic${wl_version}.tar" "${env:ORACLE_HOME}\oracle_common\jlib\cloningclient.jar"
7z a -ttar "${TEMP}\pt-weblogic${wl_version}.tar" "${env:ORACLE_HOME}\oracle_common\bin\pasteBinary.cmd"
7z a -ttar "${TEMP}\pt-weblogic${wl_version}.tar" "${TEMP}\pt-weblogic-copy.jar"

7z a -tgzip "${env:ARCHIVE_HOME}\pt-weblogic${wl_version}.tgz" "${TEMP}\pt-weblogic${wl_version}.tar"
Write-Host "`t[${computername}] [Done] Create WebLogic Tarball"

# ---------------------------------------------------------------------------------------------------------------------

###############################
## Report Times
###############################

Write-Host "`n`n"
$endDTM = (Get-Date)
$ts = New-TimeSpan -Seconds $(($endDTM-$startDTM).totalseconds)
$elapsedTime = '{0:00}:{1:00}:{2:00}' -f $ts.Hours,$ts.Minutes,$ts.Seconds
Write-Host "--------------`t--------"
Write-Host "Total Time: `t${elapsedTime}"