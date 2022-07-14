provider "azurerm" {
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  features {}
}

data "azurerm_subscription" "current"{
}

output "current_subscription_display_name" {
  value = data.azurerm_subscription.current.display_name
}

resource "azurerm_resource_group" "automate_rg" {
  count    = var.resource_group_name == null ? 1 : 0
  name     = "automate-rg"
  location = var.location
  tags     = var.tags
}

data "azurerm_resource_group" "automate_rg" {
  count    = var.resource_group_name == null ? 0 : 1
  name     = var.resource_group_name
}

resource "azurerm_automation_account" "automate" {
  name                = var.automation_account_name
  location            = var.location
  resource_group_name = local.automate_rg.name
  sku_name            = var.automation_account_sku
  tags                = var.tags
  identity {
    type = var.automation_account_identity
  }
}

resource "azurerm_role_assignment" "automate" {
    scope                   = data.azurerm_subscription.current.id
    role_definition_name    = "Contributor"
    principal_id            = azurerm_automation_account.automate.identity[0].principal_id
}

data "local_file" "automate" {
  filename                  = "${path.root}/${var.runbook_filename}"
}
resource "azurerm_automation_runbook" "automate" {
    name                      = var.automation_runbook
    resource_group_name       = local.automate_rg.name
    location                  = var.location
    automation_account_name   = azurerm_automation_account.automate.name
    log_verbose               = var.log_verbose
    log_progress              = var.log_progress
    description               = var.runbook_description
    runbook_type              = var.runbook_type

    content                   = data.local_file.automate.content
}

resource "azurerm_automation_schedule" "automate" {
  name                    = var.schedule_name
  resource_group_name     = local.automate_rg.name
  automation_account_name = azurerm_automation_account.automate.name
  frequency               = var.schedule_frequency
  interval                = var.schedule_interval
  timezone                = var.schedule_timezome
  start_time              = var.schedule_start_time
}
resource "azurerm_automation_job_schedule" "automate" {
    resource_group_name       = local.automate_rg.name
    automation_account_name   = azurerm_automation_account.automate.name
    schedule_name             = azurerm_automation_schedule.automate.name
    runbook_name              = azurerm_automation_runbook.automate.name

    parameters                = var.job_parameters
}