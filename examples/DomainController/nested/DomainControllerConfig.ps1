
<#PSScriptInfo

.VERSION 0.3.1

.GUID edd05043-2acc-48fa-b5b3-dab574621ba1

.AUTHOR Michael Greene

.COMPANYNAME Microsoft Corporation

.COPYRIGHT 

.TAGS DSCConfiguration

.LICENSEURI https://github.com/Microsoft/DomainControllerConfig/blob/master/LICENSE

.PROJECTURI https://github.com/Microsoft/DomainControllerConfig

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
https://github.com/Microsoft/DomainControllerConfig/blob/master/README.md#versions

.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core

#>

#Requires -module @{ModuleName = 'ActiveDirectoryDsc'; ModuleVersion = '6.0.1'}
#Requires -module @{ModuleName = 'StorageDsc'; ModuleVersion = '5.0.1'}
#Requires -module @{ModuleName = 'ComputerManagementDsc'; ModuleVersion = '8.4.0'}
#Requires -module @{ModuleName = 'AccessControlDsc'; ModuleVersion = '1.4.1'}
#Requires -module @{ModuleName = 'AuditPolicyDsc'; ModuleVersion = '1.4.0.0'}
#Requires -module @{ModuleName = 'AuditSystemDsc'; ModuleVersion = '1.1.0'}
#Requires -module @{ModuleName = 'FileContentDsc'; ModuleVersion = '1.3.0.151'}
#Requires -module @{ModuleName = 'GPRegistryPolicyDsc'; ModuleVersion = '1.2.0'}
#Requires -module @{ModuleName = 'PSDscResources'; ModuleVersion = '2.12.0.0'}
#Requires -module @{ModuleName = 'SecurityPolicyDsc'; ModuleVersion = '2.10.0.0'}
#Requires -module @{ModuleName = 'SqlServerDsc'; ModuleVersion = '13.3.0'}
#Requires -module @{ModuleName = 'WindowsDefenderDsc'; ModuleVersion = '2.0.0'}
#Requires -module @{ModuleName = 'xDnsServer'; ModuleVersion = '1.16.0.0'}
#Requires -module @{ModuleName = 'xWebAdministration'; ModuleVersion = '3.2.0'}
#Requires -module @{ModuleName = 'PowerSTIG'; ModuleVersion = '4.5.0'}

<#

.DESCRIPTION 
Demonstrates a minimally viable domain controller configuration script
compatible with Azure Automation Desired State Configuration service.
 
 Required variables in Automation service:
  - Credential to use for AD domain admin
  - Credential to use for Safe Mode recovery

Create these credential assets in Azure Automation,
and set their names in lines 11 and 12 of the configuration script.

Required modules in Automation service:
  - ActiveDirectoryDsc
  - ComputerManagementDsc
  - StorageDsc
  - PowerSTIG

Required modules as PowerSTIG 4.5.0 Dependencies:

  - AccessControlDsc RequiredVersion: 1.4.1
  - AuditPolicyDsc RequiredVersion: 1.4.0.0
  - AuditSystemDsc  RequiredVersion: 1.1.0
  - ComputerManagementDsc RequiredVersion: 8.4.0
  - FileContentDsc RequiredVersion: 1.3.0.151
  - GPRegistryPolicyDsc RequiredVersion: 1.2.0
  - PSDscResources RequiredVersion: 2.12.0.0
  - SecurityPolicyDsc RequiredVersion: 2.10.0.0
  - SqlServerDsc RequiredVersion: 13.3.0
  - WindowsDefenderDsc RequiredVersion: 2.0.0
  - xDnsServer RequiredVersion: 1.16.0.0
  - xWebAdministration RequiredVersion: 3.2.0

#>

configuration DomainControllerConfig
{

#Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
Import-DscResource -ModuleName @{ModuleName = 'ActiveDirectoryDsc'; ModuleVersion = '6.0.1'}
Import-DscResource -ModuleName @{ModuleName = 'StorageDsc'; ModuleVersion = '5.0.1'}
Import-DscResource -ModuleName @{ModuleName = 'ComputerManagementDsc'; ModuleVersion = '8.4.0'}
Import-DscResource -ModuleName @{ModuleName = 'AccessControlDsc'; ModuleVersion = '1.4.1'}
Import-DscResource -ModuleName @{ModuleName = 'AuditPolicyDsc'; ModuleVersion = '1.4.0.0'}
Import-DscResource -ModuleName @{ModuleName = 'AuditSystemDsc'; ModuleVersion = '1.1.0'}
Import-DscResource -ModuleName @{ModuleName = 'FileContentDsc'; ModuleVersion = '1.3.0.151'}
Import-DscResource -ModuleName @{ModuleName = 'GPRegistryPolicyDsc'; ModuleVersion = '1.2.0'}
Import-DscResource -ModuleName @{ModuleName = 'PSDscResources'; ModuleVersion = '2.12.0.0'}
Import-DscResource -ModuleName @{ModuleName = 'SecurityPolicyDsc'; ModuleVersion = '2.10.0.0'}
Import-DscResource -ModuleName @{ModuleName = 'SqlServerDsc'; ModuleVersion = '13.3.0'}
Import-DscResource -ModuleName @{ModuleName = 'WindowsDefenderDsc'; ModuleVersion = '2.0.0'}
Import-DscResource -ModuleName @{ModuleName = 'xDnsServer'; ModuleVersion = '1.16.0.0'}
Import-DscResource -ModuleName @{ModuleName = 'xWebAdministration'; ModuleVersion = '3.2.0'}
Import-DscResource -ModuleName @{ModuleName = 'PowerSTIG'; ModuleVersion = '4.5.0'}

# When using with Azure Automation, modify these values to match your stored credential names
$domainCredential = Get-AutomationPSCredential 'Credential'
$safeModeCredential = Get-AutomationPSCredential 'Credential'

  node localhost
  {
    WindowsFeature ADDSInstall
    {
        Ensure = 'Present'
        Name = 'AD-Domain-Services'
    }
    
    WaitforDisk Disk2
    {
        DiskId = 2
        RetryIntervalSec = 10
        RetryCount = 30
    }
    
    Disk DiskF
    {
        DiskId = 2
        DriveLetter = 'F'
        DependsOn = '[WaitforDisk]Disk2'
    }
    
    PendingReboot BeforeDC
    {
        Name = 'BeforeDC'
        SkipCcmClientSDK = $true
        DependsOn = '[WindowsFeature]ADDSInstall','[Disk]DiskF'
    }
    
    # Configure domain values here
    ADDomain Domain
    {
        DomainName = 'contoso.local'
        Credential = $domainCredential
        SafeModeAdministratorPassword = $safeModeCredential
        DatabasePath = 'F:\NTDS'
        LogPath = 'F:\NTDS'
        SysvolPath = 'F:\SYSVOL'
        DependsOn = '[WindowsFeature]ADDSInstall','[Disk]DiskF','[PendingReboot]BeforeDC'
    }

    WindowsServer BaseLine
    {
        OsVersion   = '2019'
        OsRole      = 'DC'
        DependsOn = '[ADDomain]Domain'
    }
  }
}