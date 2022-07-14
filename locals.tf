locals {
    automate_rg= ( var.resource_group_name == null
                    ? azurerm_resource_group.automate_rg.0
                    : data.azurerm_resource_group.automate_rg.0
                 )
}