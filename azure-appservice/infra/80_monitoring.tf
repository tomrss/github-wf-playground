
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${local.project}-law"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  tags                = var.tags
}

resource "azurerm_application_insights" "app_insights" {
  name                = "${local.project}-appinsights"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  application_type    = "other"
  workspace_id        = azurerm_log_analytics_workspace.law.id
  tags                = var.tags
}
