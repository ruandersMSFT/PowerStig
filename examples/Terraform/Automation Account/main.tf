terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = ">= 2.26"
        }
    }
}

provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" automationRg {
    name = "Automation"
    location = "usgovtexas"
}


resource "azurerm_automation_account" "automationAccount" {
  name                = "automationAccount1"
  location            = azurerm_resource_group.automationRg.location
  resource_group_name = azurerm_resource_group.automationRg.name

  sku_name = "Basic"

  tags = {
    environment = "development"
  }
}

resource "azurerm_template_deployment" "ActiveDirectoryDsc" {
    name = "ActiveDirectoryDsc_deployment_${substr(tostring(uuid()), 0, 8)}"
    resource_group_name = azurerm_resource_group.automationRg.name
    deployment_mode = "Incremental"
    template_body = file("${path.root}/AutomationAccounts.module.json")

    parameters = {
        automationAccount = azurerm_automation_account.automationAccount.name
        moduleName = "ActiveDirectoryDsc"
        contentLink = "https://www.powershellgallery.com/api/v2/package/ActiveDirectoryDsc/6.0.1"
        location = azurerm_resource_group.automationRg.location
    }

    lifecycle {
        ignore_changes = [
            name
        ]
    }
}

resource "azurerm_template_deployment" "AuditPolicyDsc" {
    name = "AuditPolicyDsc_deployment_${substr(tostring(uuid()), 0, 8)}"
    resource_group_name = azurerm_resource_group.automationRg.name
    deployment_mode = "Incremental"
    template_body = file("${path.root}/AutomationAccounts.module.json")

    parameters = {
        automationAccount = azurerm_automation_account.automationAccount.name
        moduleName = "AuditPolicyDsc"
        contentLink = "https://www.powershellgallery.com/api/v2/package/AuditPolicyDsc/1.4.0.0"
        location = azurerm_resource_group.automationRg.location
    }

    lifecycle {
        ignore_changes = [
            name
        ]
    }

    depends_on = [
        azurerm_template_deployment.ActiveDirectoryDsc
        ]
}

resource "azurerm_template_deployment" "AuditSystemDsc" {
    name = "AuditSystemDsc_deployment_${substr(tostring(uuid()), 0, 8)}"
    resource_group_name = azurerm_resource_group.automationRg.name
    deployment_mode = "Incremental"
    template_body = file("${path.root}/AutomationAccounts.module.json")

    parameters = {
        automationAccount = azurerm_automation_account.automationAccount.name
        moduleName = "AuditSystemDsc"
        contentLink = "https://www.powershellgallery.com/api/v2/package/AuditSystemDsc/1.1.0"
        location = azurerm_resource_group.automationRg.location
    }

    lifecycle {
        ignore_changes = [
            name
        ]
    }

    depends_on = [
        azurerm_template_deployment.AuditPolicyDsc
        ]
}

resource "azurerm_template_deployment" "AccessControlDsc" {
    name = "AccessControlDsc_deployment_${substr(tostring(uuid()), 0, 8)}"
    resource_group_name = azurerm_resource_group.automationRg.name
    deployment_mode = "Incremental"
    template_body = file("${path.root}/AutomationAccounts.module.json")

    parameters = {
        automationAccount = azurerm_automation_account.automationAccount.name
        moduleName = "AccessControlDsc"
        contentLink = "https://www.powershellgallery.com/api/v2/package/AccessControlDsc/1.4.1"
        location = azurerm_resource_group.automationRg.location
    }

    lifecycle {
        ignore_changes = [
            name
        ]
    }

    depends_on = [
        azurerm_template_deployment.AuditSystemDsc
        ]
}

resource "azurerm_template_deployment" "ComputerManagementDsc" {
    name = "ComputerManagementDsc_deployment_${substr(tostring(uuid()), 0, 8)}"
    resource_group_name = azurerm_resource_group.automationRg.name
    deployment_mode = "Incremental"
    template_body = file("${path.root}/AutomationAccounts.module.json")

    parameters = {
        automationAccount = azurerm_automation_account.automationAccount.name
        moduleName = "ComputerManagementDsc"
        contentLink = "https://www.powershellgallery.com/api/v2/package/ComputerManagementDsc/8.4.0"
        location = azurerm_resource_group.automationRg.location
    }

    lifecycle {
        ignore_changes = [
            name
        ]
    }

    depends_on = [
        azurerm_template_deployment.AccessControlDsc
        ]
}

resource "azurerm_template_deployment" "FileContentDsc" {
    name = "FileContentDsc_deployment_${substr(tostring(uuid()), 0, 8)}"
    resource_group_name = azurerm_resource_group.automationRg.name
    deployment_mode = "Incremental"
    template_body = file("${path.root}/AutomationAccounts.module.json")

    parameters = {
        automationAccount = azurerm_automation_account.automationAccount.name
        moduleName = "FileContentDsc"
        contentLink = "https://www.powershellgallery.com/api/v2/package/FileContentDsc/1.3.0.151"
        location = azurerm_resource_group.automationRg.location
    }

    lifecycle {
        ignore_changes = [
            name
        ]
    }

    depends_on = [
        azurerm_template_deployment.ComputerManagementDsc
        ]
}

resource "azurerm_template_deployment" "GPRegistryPolicyDsc" {
    name = "GPRegistryPolicyDsc_deployment_${substr(tostring(uuid()), 0, 8)}"
    resource_group_name = azurerm_resource_group.automationRg.name
    deployment_mode = "Incremental"
    template_body = file("${path.root}/AutomationAccounts.module.json")

    parameters = {
        automationAccount = azurerm_automation_account.automationAccount.name
        moduleName = "GPRegistryPolicyDsc"
        contentLink = "https://www.powershellgallery.com/api/v2/package/GPRegistryPolicyDsc/1.2.0"
        location = azurerm_resource_group.automationRg.location
    }

    lifecycle {
        ignore_changes = [
            name
        ]
    }

    depends_on = [
        azurerm_template_deployment.FileContentDsc
        ]
}

resource "azurerm_template_deployment" "PSDscResources" {
    name = "PSDscResources_deployment_${substr(tostring(uuid()), 0, 8)}"
    resource_group_name = azurerm_resource_group.automationRg.name
    deployment_mode = "Incremental"
    template_body = file("${path.root}/AutomationAccounts.module.json")

    parameters = {
        automationAccount = azurerm_automation_account.automationAccount.name
        moduleName = "PSDscResources"
        contentLink = "https://www.powershellgallery.com/api/v2/package/PSDscResources/2.12.0.0"
        location = azurerm_resource_group.automationRg.location
    }

    lifecycle {
        ignore_changes = [
            name
        ]
    }

    depends_on = [
        azurerm_template_deployment.GPRegistryPolicyDsc
        ]
}

resource "azurerm_template_deployment" "SecurityPolicyDsc" {
    name = "SecurityPolicyDsc_deployment_${substr(tostring(uuid()), 0, 8)}"
    resource_group_name = azurerm_resource_group.automationRg.name
    deployment_mode = "Incremental"
    template_body = file("${path.root}/AutomationAccounts.module.json")

    parameters = {
        automationAccount = azurerm_automation_account.automationAccount.name
        moduleName = "SecurityPolicyDsc"
        contentLink = "https://www.powershellgallery.com/api/v2/package/SecurityPolicyDsc/2.10.0.0"
        location = azurerm_resource_group.automationRg.location
    }

    lifecycle {
        ignore_changes = [
            name
        ]
    }

    depends_on = [
        azurerm_template_deployment.PSDscResources
        ]
}

resource "azurerm_template_deployment" "StorageDsc" {
    name = "StorageDsc_deployment_${substr(tostring(uuid()), 0, 8)}"
    resource_group_name = azurerm_resource_group.automationRg.name
    deployment_mode = "Incremental"
    template_body = file("${path.root}/AutomationAccounts.module.json")

    parameters = {
        automationAccount = azurerm_automation_account.automationAccount.name
        moduleName = "StorageDsc"
        contentLink = "https://www.powershellgallery.com/api/v2/package/StorageDsc/5.0.1"
        location = azurerm_resource_group.automationRg.location
    }

    lifecycle {
        ignore_changes = [
            name
        ]
    }

    depends_on = [
        azurerm_template_deployment.SecurityPolicyDsc
        ]
}

resource "azurerm_template_deployment" "SqlServerDsc" {
    name = "SqlServerDsc_deployment_${substr(tostring(uuid()), 0, 8)}"
    resource_group_name = azurerm_resource_group.automationRg.name
    deployment_mode = "Incremental"
    template_body = file("${path.root}/AutomationAccounts.module.json")

    parameters = {
        automationAccount = azurerm_automation_account.automationAccount.name
        moduleName = "SqlServerDsc"
        contentLink = "https://www.powershellgallery.com/api/v2/package/SqlServerDsc/13.3.0"
        location = azurerm_resource_group.automationRg.location
    }

    lifecycle {
        ignore_changes = [
            name
        ]
    }

    depends_on = [
        azurerm_template_deployment.StorageDsc
        ]
}

resource "azurerm_template_deployment" "WindowsDefenderDsc" {
    name = "WindowsDefenderDsc_deployment_${substr(tostring(uuid()), 0, 8)}"
    resource_group_name = azurerm_resource_group.automationRg.name
    deployment_mode = "Incremental"
    template_body = file("${path.root}/AutomationAccounts.module.json")

    parameters = {
        automationAccount = azurerm_automation_account.automationAccount.name
        moduleName = "WindowsDefenderDsc"
        contentLink = "https://www.powershellgallery.com/api/v2/package/WindowsDefenderDsc/2.0.0"
        location = azurerm_resource_group.automationRg.location
    }

    lifecycle {
        ignore_changes = [
            name
        ]
    }

    depends_on = [
        azurerm_template_deployment.SqlServerDsc
        ]
}

resource "azurerm_template_deployment" "xDnsServer" {
    name = "xDnsServer_deployment_${substr(tostring(uuid()), 0, 8)}"
    resource_group_name = azurerm_resource_group.automationRg.name
    deployment_mode = "Incremental"
    template_body = file("${path.root}/AutomationAccounts.module.json")

    parameters = {
        automationAccount = azurerm_automation_account.automationAccount.name
        moduleName = "xDnsServer"
        contentLink = "https://www.powershellgallery.com/api/v2/package/xDnsServer/1.16.0.0"
        location = azurerm_resource_group.automationRg.location
    }

    lifecycle {
        ignore_changes = [
            name
        ]
    }

    depends_on = [
        azurerm_template_deployment.WindowsDefenderDsc
        ]
}

resource "azurerm_template_deployment" "xWebAdministration" {
    name = "xWebAdministration_deployment_${substr(tostring(uuid()), 0, 8)}"
    resource_group_name = azurerm_resource_group.automationRg.name
    deployment_mode = "Incremental"
    template_body = file("${path.root}/AutomationAccounts.module.json")

    parameters = {
        automationAccount = azurerm_automation_account.automationAccount.name
        moduleName = "xWebAdministration"
        contentLink = "https://www.powershellgallery.com/api/v2/package/xWebAdministration/3.2.0"
        location = azurerm_resource_group.automationRg.location
    }

    lifecycle {
        ignore_changes = [
            name
        ]
    }

    depends_on = [
        azurerm_template_deployment.xDnsServer
        ]
}

resource "azurerm_template_deployment" "PowerSTIG" {
    name = "PowerSTIG_deployment_${substr(tostring(uuid()), 0, 8)}"
    resource_group_name = azurerm_resource_group.automationRg.name
    deployment_mode = "Incremental"
    template_body = file("${path.root}/AutomationAccounts.module.json")

    parameters = {
        automationAccount = azurerm_automation_account.automationAccount.name
        moduleName = "PowerSTIG"
        contentLink = "https://www.powershellgallery.com/api/v2/package/PowerSTIG/4.5.0"
        location = azurerm_resource_group.automationRg.location
    }

    lifecycle {
        ignore_changes = [
            name
        ]
    }

    depends_on = [
        azurerm_template_deployment.ActiveDirectoryDsc,
        azurerm_template_deployment.AuditPolicyDsc,
        azurerm_template_deployment.AuditSystemDsc,
        azurerm_template_deployment.AccessControlDsc,
        azurerm_template_deployment.ComputerManagementDsc,
        azurerm_template_deployment.FileContentDsc,
        azurerm_template_deployment.GPRegistryPolicyDsc,
        azurerm_template_deployment.PSDscResources,
        azurerm_template_deployment.SecurityPolicyDsc,
        azurerm_template_deployment.StorageDsc,
        azurerm_template_deployment.SqlServerDsc,
        azurerm_template_deployment.WindowsDefenderDsc,
        azurerm_template_deployment.xDnsServer,
        azurerm_template_deployment.xWebAdministration
        ]
}