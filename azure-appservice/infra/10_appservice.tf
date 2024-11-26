

resource "azurerm_service_plan" "app" {
  name                = "${local.project}-app-plan"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku_name            = "P0v3"
  os_type             = "Linux"
  tags                = var.tags
}

module "app_dev" {
  source = "../../modules/azure_appservice/"

  name                             = "${local.project}-app-dev"
  location                         = data.azurerm_resource_group.rg.location
  resource_group_name              = data.azurerm_resource_group.rg.name
  service_plan_id                  = azurerm_service_plan.app.id
  docker_image_name                = local.docker_image
  docker_registry_url              = local.docker_registry
  app_insights_connection_string   = azurerm_application_insights.app_insights.connection_string
  app_insights_instrumentation_key = azurerm_application_insights.app_insights.instrumentation_key
  log_analytics_workspace_id       = azurerm_log_analytics_workspace.law.id
  health_check_path                = local.health_path

  production_slot_settings = {
    APP_ENV = "DEV"
  }
  staging_slot_settings = {
    APP_ENV = "DEV-staging"
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone" "privatelink_azurewebsites_net" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_azurewebsites_net_vnet" {
  name                  = azurerm_virtual_network.this.name
  resource_group_name   = azurerm_virtual_network.this.resource_group_name
  virtual_network_id    = azurerm_virtual_network.this.id
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_azurewebsites_net.name
}

module "app_fakeprod" {
  source = "../../modules/azure_appservice/"

  name                             = "${local.project}-app-fakeprod"
  location                         = data.azurerm_resource_group.rg.location
  resource_group_name              = data.azurerm_resource_group.rg.name
  service_plan_id                  = azurerm_service_plan.app.id
  docker_image_name                = local.docker_image
  docker_registry_url              = local.docker_registry
  app_insights_connection_string   = azurerm_application_insights.app_insights.connection_string
  app_insights_instrumentation_key = azurerm_application_insights.app_insights.instrumentation_key
  log_analytics_workspace_id       = azurerm_log_analytics_workspace.law.id
  health_check_path                = local.health_path

  networking = {
    public_network_access_enabled = false
    network_integration_enabled   = true
    network_integration_subnet_id = azurerm_subnet.app.id
    private_endpoint_enabled      = true
    private_endpoint_subnet_id    = azurerm_subnet.private_endpoints.id
    private_dns_zone_ids          = [azurerm_private_dns_zone.privatelink_azurewebsites_net.id]
  }

  production_slot_settings = {
    APP_ENV = "FAKEPROD"
  }
  staging_slot_settings = {
    APP_ENV = "FAKEPROD-staging"
  }

  tags = var.tags
}
