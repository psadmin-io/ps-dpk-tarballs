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

$env:ARCHIVE_HOME   = "c:\vagrant\dpks\archives"
$env:ORACLE_HOME    = $(hiera weblogic_location)
$env:JAVA_HOME      = $(hiera jdk_location)

# $env:ORACLE_HOME="c:\psft\pt\bea"
# $env:JAVA_HOME="c:\psft\pt\jdk1.7.0_101"
# $wl_version="12.1.3.170418"
# $jdk_version="1.7.0_141"

# Java

7z a -ttar "${env:TEMP}\pt-jdk${jdk_version}.tar" $env:JAVA_HOME\*
7z a -tgzip "${env:ARCHIVE_HOME}\pt-jdk${jdk_version}.tgz" "${env:TEMP}\pt-jdk${jdk_version}.tar"

# WebLogic

. ${env:ORACLE_HOME}\oracle_common\bin\copyBinary.cmd -javaHome ${env:JAVA_HOME} -archiveLoc ${env:TEMP}\pt-weblogic-copy.jar -sourceMWHomeLoc ${env:ORACLE_HOME}

7z a -ttar "${env:TEMP}\pt-weblogic${wl_version}.tar" "${env:ORACLE_HOME}\oracle_common\jlib\cloningclient.jar"
7z a -ttar "${env:TEMP}\pt-weblogic${wl_version}.tar" "${env:ORACLE_HOME}\oracle_common\bin\pasteBinary.cmd"
7z a -ttar "${env:TEMP}\pt-weblogic${wl_version}.tar" "${env:TEMP}\pt-weblogic-copy.jar"

7z a -tgzip "${env:ARCHIVE_HOME}\pt-weblogic${wl_version}.tgz" "${env:TEMP}\pt-weblogic${wl_version}.tar"