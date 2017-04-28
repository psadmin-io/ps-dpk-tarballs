<#
.Synopsis
   Patch WebLogic and Java
.DESCRIPTION
   This script will:
   1. Copy new DPK archives to server
   2. Stop PeopleSoft Services
   3. Remove current Java and WebLogic installs
   4. Run middleware.pp to install patched Java and WebLogic
   5. Start PeopleSoft Services
.EXAMPLE
   PS E:\psft\tools> .\cpu.ps1 -jdk_version 1.7.0_141 -wl_version 12.1.3.0.170418 
.INPUTS
    JDK Version 
    WebLogic Version
#>

$computername = (Get-WmiObject Win32_Computersystem).Name.toLower()

Write-Host "`n`nDeploying CPU Patches on ${computername}"
Write-Host "`tJDK Archive: `t`tpt-jdk${jdk_version}"          -ForegroundColor Green
Write-Host "`tWebLogic Archive: `tpt-weblogic${wl_version}"   -ForegroundColor Green
Write-Host "`n"

## 1. Copy new DPK Archives to the Server
Write-Host "`t[${computername}] [Task] Remove Current Archives"
remove-item e:\psft\dpk\archives\pt-jdk*
remove-item e:\psft\dpk\archives\pt-weblogic*
Write-Host "`t[${computername}] [Done] Remove Current Archives"

Write-Host "`t[${computername}] [Task] Copy New Archives"
copy-item c:\vagrant\dpk\archives\pt-jdk${jdk_version}.tgz e:\psft\dpk\archives\
copy-item c:\vagrant\dpk\archives\pt-weblogic${wl_version}.tgz \e:\psft\dpk\archives\
Write-Host "`t[${computername}] [Done] Copy New Archives"

## 2. Stop PeopleSoft Services
Write-Host "`t[${computername}] [Task] Stop PIA Domains"
get-service -DisplayName Psft*,*Oracle* | stop-service
Get-Process rmiregistry -ErrorAction SilentlyContinue | Stop-Process -Force
Write-Host "`t[${computername}] [Done] Stop PIA Domains"

## 3. Remove current Java and WebLogic installs
Write-Host "`t[${computername}] [Task] Remove Unpatched Software"
remove-item e:\oracle\weblogic -recurse -force
if (-Not (test-path e:\oracle\empty)) { mkdir e:\oracle\empty }
robocopy e:\oracle\empty e:\oracle\weblogic /MIR 
remove-item e:\oracle\empty
remove-item e:\java\* -recurse -force
Write-Host "`t[${computername}] [Done] Remove Unpatched Software"

## 4. Run middleware.pp to install patched Java and WebLogic
Write-Host "`t[${computername}] [Task] Deploy Patched Software"
puppet apply c:\programdata\puppetlabs\puppet\etc\manifests\middleware.pp --trace --debug
Write-Host "`t[${computername}] [Done] Deploy Patched Software"

## 5. Start PeopleSoft Services
Write-Host "`t[${computername}] [Task] Start PIA Domains"
get-service -name *${pt_version}-pia | start-service
Write-Host "`t[${computername}] [Task] Start PIA Domains"

