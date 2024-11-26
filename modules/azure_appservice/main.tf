locals {
  default_app_settings = {
    WEBSITE_SWAP_WARMUP_PING_PATH                   = var.health_check_path
    WEBSITE_SWAP_WARMUP_PING_STATUSES               = "200"
    WEBSITE_WARMUP_PATH                             = var.health_check_path
    APPINSIGHTS_INSTRUMENTATIONKEY                  = var.app_insights_instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING           = var.app_insights_connection_string
    APPINSIGHTS_PROFILERFEATURE_VERSION             = "1.0.0"
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION             = "1.0.0"
    ApplicationInsightsAgent_EXTENSION_VERSION      = "~2"
    DiagnosticServices_EXTENSION_VERSION            = "~3"
    InstrumentationEngine_EXTENSION_VERSION         = "~2"
    SnapshotDebugger_EXTENSION_VERSION              = "1.0.15"
    XDT_MicrosoftApplicationInsights_BaseExtensions = "disabled"
    XDT_MicrosoftApplicationInsights_Mode           = "recommended"
    XDT_MicrosoftApplicationInsights_PreemptSdk     = "disabled"
  }
  app_settings = merge(
    local.default_app_settings,
    var.app_settings,
  )
}

resource "azurerm_linux_web_app" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  service_plan_id               = var.service_plan_id
  client_certificate_enabled    = false
  https_only                    = true
  client_affinity_enabled       = false
  public_network_access_enabled = var.networking.public_network_access_enabled

  app_settings = merge(
    local.app_settings,
    var.production_slot_settings,
  )

  site_config {
    always_on                         = true
    use_32_bit_worker                 = false
    ftps_state                        = "Disabled"
    http2_enabled                     = true
    minimum_tls_version               = "1.2"
    scm_minimum_tls_version           = "1.2"
    vnet_route_all_enabled            = true
    health_check_eviction_time_in_min = 2
    health_check_path                 = var.health_check_path

    application_stack {
      docker_image_name   = var.docker_image_name
      docker_registry_url = var.docker_registry_url
    }
  }

  identity {
    type         = var.identity.type
    identity_ids = var.identity.identity_ids
  }

  logs {
    detailed_error_messages = false
    failed_request_tracing  = false
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 100
      }
    }
  }

  lifecycle {
    ignore_changes = [
      virtual_network_subnet_id,
      site_config[0].application_stack[0].docker_image_name,
      app_settings["WEBSITE_HEALTHCHECK_MAXPINGFAILURES"],
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
    ]
  }

  tags = var.tags
}

resource "azurerm_linux_web_app_slot" "staging" {
  count = var.staging_slot_enabled ? 1 : 0

  app_service_id                = azurerm_linux_web_app.this.id
  name                          = "staging"
  client_certificate_enabled    = false
  https_only                    = true
  client_affinity_enabled       = false
  public_network_access_enabled = var.networking.public_network_access_enabled

  app_settings = merge(
    local.app_settings,
    var.staging_slot_settings,
  )

  site_config {
    always_on                         = true
    use_32_bit_worker                 = false
    ftps_state                        = "Disabled"
    http2_enabled                     = true
    minimum_tls_version               = "1.2"
    scm_minimum_tls_version           = "1.2"
    vnet_route_all_enabled            = true
    health_check_eviction_time_in_min = 2
    health_check_path                 = var.health_check_path

    application_stack {
      docker_image_name   = var.docker_image_name
      docker_registry_url = var.docker_registry_url
    }
  }

  identity {
    type         = var.identity.type
    identity_ids = var.identity.identity_ids
  }

  logs {
    detailed_error_messages = false
    failed_request_tracing  = false
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 100
      }
    }
  }

  lifecycle {
    ignore_changes = [
      virtual_network_subnet_id,
      site_config[0].application_stack[0].docker_image_name,
      app_settings["WEBSITE_HEALTHCHECK_MAXPINGFAILURES"],
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
    ]
  }

  tags = var.tags
}

data "azurerm_monitor_diagnostic_categories" "categories" {
  resource_id = azurerm_linux_web_app.this.id
}

resource "azurerm_monitor_diagnostic_setting" "diagnostic_setting" {
  name                       = "${var.name}-diagnostic"
  target_resource_id         = azurerm_linux_web_app.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.categories.metrics
    content {
      category = metric.value
      enabled  = true
    }
  }

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.categories.log_category_types
    content {
      category = enabled_log.value
    }
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "app" {
  count = var.networking.network_integration_enabled ? 1 : 0

  app_service_id = azurerm_linux_web_app.this.id
  subnet_id      = var.networking.network_integration_subnet_id
}

resource "azurerm_private_endpoint" "app" {
  count = var.networking.private_endpoint_enabled ? 1 : 0

  name                = "${var.name}-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.networking.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name}-endpoint"
    private_connection_resource_id = azurerm_linux_web_app.this.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = var.networking.private_dns_zone_ids
  }

  tags = var.tags
}

resource "azurerm_app_service_slot_virtual_network_swift_connection" "app_staging" {
  count = var.staging_slot_enabled && var.networking.network_integration_enabled ? 1 : 0

  slot_name      = azurerm_linux_web_app_slot.staging[0].name
  app_service_id = azurerm_linux_web_app.this.id
  subnet_id      = var.networking.network_integration_subnet_id
}

resource "azurerm_private_endpoint" "app_staging" {
  # read this comment to learn how configure private endpoint for slot:
  # https://github.com/hashicorp/terraform-provider-azurerm/issues/17551#issuecomment-1233084688
  count = var.staging_slot_enabled && var.networking.private_endpoint_enabled ? 1 : 0

  name                = "${var.name}-staging-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.networking.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name}-endpoint"
    private_connection_resource_id = azurerm_linux_web_app.this.id
    is_manual_connection           = false
    subresource_names              = ["sites-${azurerm_linux_web_app_slot.staging[0].name}"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = var.networking.private_dns_zone_ids
  }

  tags = var.tags
}
