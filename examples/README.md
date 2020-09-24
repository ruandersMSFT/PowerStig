Documentation todo....

Domain Controller

[![Deploy To Azure](https://raw.githubusercontent.com/ruandersMSFT/PowerStig/dev-ARMTemplates/examples/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FruandersMSFT%2FPowerStig%2Fdev-ARMTemplates%2Fexamples%2FDomainController%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/ruandersMSFT/PowerStig/dev-ARMTemplates/examples/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FruandersMSFT%2FPowerStig%2Fdev-ARMTemplates%2Fexamples%2FDomainController%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/ruandersMSFT/PowerStig/dev-ARMTemplates/examples/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FruandersMSFT%2FPowerStig%2Fdev-ARMTemplates%2Fexamples%2FDomainController%2Fazuredeploy.json)













## PowerSTIG with Azure Automation
PowerSTIG paired with Azure Automation enables better insight into the DSC status of nodes, reporting and visualization of data when logs are fowarded to Log Analytics. 

## Importing Required Modules into Azure Automation Environment 
PowerSTIG (4.5.0) has several modules dependenies that will need to be imported into an Azure automation environment before the PowerSTIG module can be imported. 

* Manage Modules in Azure Automation: https://docs.microsoft.com/en-us/azure/automation/shared-resources/modules

* Example ARM template that can be used to import the PowerSTIG module and require dependencies:  https://github.com/mikedzikowski/azure-import-powerstig-azureautomation   

**Dependencies:** 
* AccessControlDsc RequiredVersion: 1.4.1
* AuditPolicyDsc RequiredVersion: 1.4.0.0
* AuditSystemDsc  RequiredVersion: 1.1.0
* ComputerManagementDsc RequiredVersion: 8.4.0
* FileContentDsc RequiredVersion: 1.3.0.151
* GPRegistryPolicyDsc RequiredVersion: 1.2.0
* PSDscResources RequiredVersion: 2.12.0.0
* SecurityPolicyDsc RequiredVersion: 2.10.0.0
* SqlServerDsc RequiredVersion: 13.3.0
* WindowsDefenderDsc RequiredVersion: 2.0.0
* xDnsServer RequiredVersion: 1.16.0.0
* xWebAdministration RequiredVersion: 3.2.0


## Example PowerShell that may be used to import PowerSTIG dependencies

The following PowerShell will script will import the PowerSTIG dependencies into an existing Azure Automation environment. For more informationon how to install PowerSTIG please reference: https://github.com/microsoft/PowerStig 

**Note:** PowerSTIG requires a number of dependent DSC modules, and the version of theses modules will most likely change over time.  To ensure you have the correct required modules run this code. **If the modules fail to load, please run this script a second time. **

```powershell
[CmdletBinding()] 
param 
(  
    [Parameter(mandatory=$true)]
    [string]
    $ResourceGroupName,

    [Parameter(mandatory=$true)]
    [string]
    $AutomationAccountName
) 
#region Login to Azure
try
{
    Write-output "Logging in to Azure..." 
    $azEnvironment = read-host "Please select an Azure Environment   1: Azure Government  or  2: Azure Commercial"
    if ($azEnvironment -eq 1)
    {    
        Add-AzAccount -EnvironmentName "AzureUSGovernment" | Out-Null
    }
    elseif ($azEnvironment -eq 2)
    {
        Add-AzAccount | Out-Null
    }
    else
    {
        throw "Please enter 1 for Azure Government and 2 for Azure Commercial"
    }
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

# Find PowerSTIG module 
try 
{    
    $powerStig = (Get-module -Name PowerSTIG -ListAvailable)

    if(!$powerStig)
    {
        Import-Module -Name PowerSTIG
        $powerStig = (Get-module -Name PowerSTIG -ListAvailable)
    }
}
catch 
{
    Write-Error -Message $_.Exception
    throw $_.Exception
}

# Find the required modules for PowerSTIG
$requiredModules = (Import-PowerShellDataFile -Path (Get-Module PowerSTIG -list).path).RequiredModules 

# Create empty hashtable 
$dependencies = @()

# Add the modules to an hashtable 
foreach($module in $requiredModules)
{
    $dependencies +=  @{ModuleName = $module.ModuleName; RequiredVersion = $module.ModuleVersion; }
}

#region Import PowerSTIG dependencies and PowerSTIG version 4.5.0
foreach($dependency in $dependencies)
{
    $galleryRepoUri = "https://www.powershellgallery.com/api/v2/package/" + $dependency.ModuleName + "/" + $dependency.RequiredVersion
    $galleryRepoUri
    New-AzAutomationModule -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $dependency.ModuleName -ContentLink $galleryRepoUri
}
# Import PowerSTIG into Azure Automation
if($powerStig)
{
    $galleryRepoUri = "https://www.powershellgallery.com/api/v2/package/" + $powerStig.Name + "/" + $powerStig.Version
    $galleryRepoUri
    New-AzAutomationModule -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $powerStig.Name -ContentLink $galleryRepoUri
}
else 
{
    write-host "Please Install PowerSTIG by running: Install-Module -Name PowerStig -Scope CurrentUser"
}
#endregion  
``` 

## Importing PowerSTIG Desired State Configuration (DSC) into Azure Automation
The following code will import a PowerSTIG Desired State Configuration from a PS1 file into Azure Automation.

For additional details on the Import-AzAutomationDscConfiguration cmdlet please reference the following link: 
https://docs.microsoft.com/en-us/powershell/module/az.automation/import-azautomationdscconfiguration?view=azps-2.6.0

```powershell
[CmdletBinding()] 
param 
(  
    [Parameter(mandatory=$true)]
    [string]
    $ResourceGroupName,

    [Parameter(mandatory=$true)]
    [string]
    $AutomationAccountName,

    [Parameter(mandatory=$true)]
    [string]
    $SourcePath
) 

# Imports Azure Automation DSC Configuration from PS1 provided in $SourcePath 
try 
{
    Import-AzAutomationDscConfiguration -AutomationAccountName $automationAccountName -ResourceGroupName $resourceGroupName -SourcePath $sourcePath -Force
}
catch
{
    Write-Error -Message $_.Exception
    throw $_.Exception
}
```

## Azure Automation Desired State Configuration Onboarding 

To onboard a machine for management by Azure Automation State Configuration please referece the following documentation: https://docs.microsoft.com/en-us/azure/automation/automation-dsc-onboarding 

## Forwarding Azure Automation Desired State Configuration Status Using Log Analytics

Data from Azure State Configuration can be forwarded to Log Analytics. The following link provides the steps required to configure log fowarding for DSC configurations. 

Azure State Configuration data can be fowarded by following this set of documentation: https://docs.microsoft.com/en-us/azure/automation/automation-dsc-diagnostics 

## Sample Queries for Reporting on Desired State Configuration Status with Log Analytics

* Find all resources that are not compliant 
```powershell
AzureDiagnostics
| where DscResourceStatus_s != "Compliant"
| summarize count() by tostring(DscResourceId_s), DscModuleName_s, bin(TimeGenerated, 4h) 
``` 
![ExampleQueryOutput1](images/ExampleDSCQuery1.jpg)

* Find all DSC resources that are not complaint per node
```powershell
AzureDiagnostics
| where DscResourceStatus_s == "NotCompliant"
| where DscConfigurationName_s == <DSC CONFIGURATION NAME>
| where NodeName_s == <NODE NAME>
| distinct NodeName_s , DscResourceId_s, DscResourceStatus_s   
``` 
![ExampleQueryOutput2](images/ExampleDSCQuery2.jpg)

## PowerSTIG User Voice Feedback
* [PowerSTIG Module Import in Azure Automation](https://feedback.azure.com/forums/246290-automation/suggestions/38561443-powerstig-module-import-in-azure-automation)

