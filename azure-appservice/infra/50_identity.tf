data "azurerm_resource_group" "default_assignment_rg" {
  name = "default-roleassignment-rg"
}

resource "azurerm_user_assigned_identity" "cd_dev" {
  name                = "${local.project}-cd-dev-id"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags                = var.tags
}

resource "azurerm_role_assignment" "cd_dev_default_role_assignment" {
  scope                = data.azurerm_resource_group.default_assignment_rg.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.cd_dev.principal_id
}

resource "azurerm_role_assignment" "cd_dev_app_contributor" {
  scope                = module.app_dev.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.cd_dev.principal_id
}

resource "azurerm_role_assignment" "cd_dev_app_staging_contributor" {
  scope                = module.app_dev.staging_slot_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.cd_dev.principal_id
}

resource "azurerm_federated_identity_credential" "environment_dev" {
  parent_id           = azurerm_user_assigned_identity.cd_dev.id
  resource_group_name = data.azurerm_resource_group.rg.name
  name                = "github-federated"
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  subject             = "repo:${var.github.org}/${var.github.repository}:environment:${github_repository_environment.dev.environment}"
}

# fakeprod is not really prod!

resource "azurerm_user_assigned_identity" "cd_fakeprod" {
  name                = "${local.project}-cd-fakeprod-id"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags                = var.tags
}


resource "azurerm_role_assignment" "cd_fakeprod_default_role_assignment" {
  scope                = data.azurerm_resource_group.default_assignment_rg.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.cd_fakeprod.principal_id
}

resource "azurerm_role_assignment" "cd_fakeprod_app_contributor" {
  scope                = module.app_fakeprod.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.cd_fakeprod.principal_id
}

resource "azurerm_role_assignment" "cd_fakeprod_app_staging_contributor" {
  scope                = module.app_fakeprod.staging_slot_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.cd_fakeprod.principal_id
}

resource "azurerm_federated_identity_credential" "environment_fakeprod" {
  parent_id           = azurerm_user_assigned_identity.cd_fakeprod.id
  resource_group_name = data.azurerm_resource_group.rg.name
  name                = "github-federated"
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  subject             = "repo:${var.github.org}/${var.github.repository}:environment:${github_repository_environment.fakeprod.environment}"
}
