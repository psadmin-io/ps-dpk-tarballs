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
   PS c:\psft\tools> .\cpu.ps1 -jdk_version 1.7.0_141 -wl_version 12.1.3.0.170418 
.INPUTS
    JDK Version 
    WebLogic Version
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]$jdk_version,
    [Parameter(Mandatory=$true)]$wl_version
)

$computername = (Get-WmiObject Win32_Computersystem).Name.toLower()
$startDTM = (Get-Date)

# ---------------------------------------------------------------------------------------------------------------------

Write-Host "`n`nDeploying CPU Patches on ${computername}"
Write-Host "`tJDK Archive: `t`tpt-jdk${jdk_version}"          -ForegroundColor Green
Write-Host "`tWebLogic Archive: `tpt-weblogic${wl_version}"   -ForegroundColor Green
Write-Host "`n"

# ---------------------------------------------------------------------------------------------------------------------

#########################################
## 1. Copy new DPK Archives to the Server
#########################################

Write-Host "`t[${computername}] [Task] Remove Current Archives"
remove-item c:\psft\dpk\archives\pt-jdk*
remove-item c:\psft\dpk\archives\pt-weblogic*
Write-Host "`t[${computername}] [Done] Remove Current Archives"

Write-Host "`t[${computername}] [Task] Copy New Archives"
copy-item c:\vagrant\dpk\archives\pt-jdk${jdk_version}.tgz c:\psft\dpk\archives\
copy-item c:\vagrant\dpk\archives\pt-weblogic${wl_version}.tgz c:\psft\dpk\archives\
Write-Host "`t[${computername}] [Done] Copy New Archives"

##############################
## 2. Stop PeopleSoft Services
##############################

Write-Host "`t[${computername}] [Task] Stop PIA Domains"
get-service -DisplayName Psft*,*Oracle* | stop-service -force
Get-Process rmiregistry -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process tuxipc -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process slisten -ErrorAction SilentlyContinue | Stop-Process -Force
Write-Host "`t[${computername}] [Done] Stop PIA Domains"

#############################################################################
## 3. Remove current Java and WebLogic installs if not using `redeploy: true`
#############################################################################

$redeploy = $(hiera redeploy)
if (-Not ($redeploy -eq "true")) {
  Write-Host "`t[${computername}] [Task] Remove Unpatched Software"
  # Use robocopy /MIR to bypass "path too long" issue
  if (-Not (test-path c:\psft\pt\empty)) { mkdir c:\psft\pt\empty } else { remove-item c:\psft\pt\empty\* -recurse -force }
  robocopy c:\psft\pt\empty c:\psft\pt\bea\ /MIR /XD c:\psft\pt\bea\tuxedo
  remove-item c:\psft\pt\empty
  remove-item c:\psft\pt\jdk* -recurse -force
  Write-Host "`t[${computername}] [Done] Remove Unpatched Software"
}

############################################################
## 4. Run middleware.pp to install patched Java and WebLogic
############################################################

Write-Host "`t[${computername}] [Task] Deploy Patched Software"
copy-item c:\vagrant\config\psft_customizations.yaml c:\programdata\puppetlabs\puppet\etc\data\psft_customizations.yaml
# Deploy custom role - io_tools_deployment.pp - for `env_type: fulltier` systems (PUM)
copy-item c:\vagrant\cpu\io_tools_deployment.pp c:\programdata\puppetlabs\puppet\etc\modules\pt_role\manifests\io_tools_deployment.pp
# Copy `middleware.pp` and run it
copy-item c:\vagrant\cpu\middleware.pp c:\programdata\puppetlabs\puppet\etc\manifests\middleware.pp
puppet apply c:\programdata\puppetlabs\puppet\etc\manifests\middleware.pp
Write-Host "`t[${computername}] [Done] Deploy Patched Software"

###############################
## 5. Start PeopleSoft Services
###############################

Write-Host "`t[${computername}] [Task] Start PIA Domains"
get-service -DisplayName Psft*,*Oracle*  | start-service
Write-Host "`t[${computername}] [Task] Start PIA Domains"


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