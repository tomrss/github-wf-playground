
variable "name" {
  type        = string
  description = "Pass-through"
}

variable "resource_group_name" {
  type        = string
  description = "Pass-through"
}

variable "location" {
  type        = string
  description = "Pass-through"
}

variable "tags" {
  type = map(any)
  default = {
    CreatedBy = "Terraform"
  }
}

variable "service_plan_id" {
  type        = string
  description = "Pass-through"
}

variable "health_check_path" {
  type        = string
  description = "Pass-through"
}

variable "app_settings" {
  default = {}

  validation {
    condition     = !contains(keys(var.app_settings), "APPINSIGHTS_INSTRUMENTATIONKEY")
    error_message = "Use app_insights_instrumentation_key instead of APPINSIGHTS_INSTRUMENTATIONKEY app setting"
  }

  validation {
    condition     = !contains(keys(var.app_settings), "APPLICATIONINSIGHTS_CONNECTION_STRING")
    error_message = "Use app_insights_connection_string instead of APPLICATIONINSIGHTS_CONNECTION_STRING app setting"
  }
}

variable "staging_slot_settings" {
  default = {}

  validation {
    condition     = !contains(keys(var.staging_slot_settings), "APPINSIGHTS_INSTRUMENTATIONKEY")
    error_message = "Use app_insights_instrumentation_key instead of APPINSIGHTS_INSTRUMENTATIONKEY app setting"
  }

  validation {
    condition     = !contains(keys(var.staging_slot_settings), "APPLICATIONINSIGHTS_CONNECTION_STRING")
    error_message = "Use app_insights_connection_string instead of APPLICATIONINSIGHTS_CONNECTION_STRING app setting"
  }
}

variable "production_slot_settings" {
  default = {}

  validation {
    condition     = !contains(keys(var.production_slot_settings), "APPINSIGHTS_INSTRUMENTATIONKEY")
    error_message = "Use app_insights_instrumentation_key instead of APPINSIGHTS_INSTRUMENTATIONKEY app setting"
  }

  validation {
    condition     = !contains(keys(var.production_slot_settings), "APPLICATIONINSIGHTS_CONNECTION_STRING")
    error_message = "Use app_insights_connection_string instead of APPLICATIONINSIGHTS_CONNECTION_STRING app setting"
  }
}

variable "app_insights_instrumentation_key" {
  type = string
}

variable "app_insights_connection_string" {
  type = string
}

variable "docker_image_name" {
  type = string
}

variable "docker_registry_url" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "identity" {
  type = object({
    type         = string
    identity_ids = optional(list(string), null)
  })
  description = "Pass-through"
  default = {
    type         = "SystemAssigned"
    identity_ids = null
  }
}

variable "networking" {
  type = object({
    public_network_access_enabled = optional(bool, null)
    network_integration_enabled   = optional(bool, false)
    network_integration_subnet_id = optional(string, null)
    private_endpoint_enabled      = optional(bool, false)
    private_endpoint_subnet_id    = optional(string, null)
    private_dns_zone_ids          = optional(list(string), null)
  })

  default = {
    public_network_access_enabled = true
    network_integration_enabled   = false
    private_endpoint_enabled      = false
  }

  # todo validate stuff
}

variable "staging_slot_enabled" {
  type    = bool
  default = true
}
