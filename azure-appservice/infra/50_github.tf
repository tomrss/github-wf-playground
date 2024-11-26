data "github_user" "current" {
  username = ""
}

resource "github_branch_protection" "main" {
  repository_id = var.github.repository

  pattern          = "main"
  enforce_admins   = false
  allows_deletions = true

  required_linear_history = true

  required_pull_request_reviews {
    dismiss_stale_reviews = true
    restrict_dismissals   = true
    pull_request_bypassers = [
      data.github_user.current.node_id
    ]
  }

  allows_force_pushes = false
  force_push_bypassers = [
    data.github_user.current.node_id
  ]

  lifecycle {
    ignore_changes = [
      required_pull_request_reviews[0].pull_request_bypassers,
      required_pull_request_reviews[0].restrict_dismissals,
    ]
  }
}

resource "github_repository_environment" "dev" {
  environment         = "dev"
  repository          = var.github.repository
  prevent_self_review = false
  can_admins_bypass   = true

  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }
}

# fakeprod is not productive, it simulates production!
resource "github_repository_environment" "fakeprod" {
  environment         = "fakeprod"
  repository          = var.github.repository
  prevent_self_review = false
  can_admins_bypass   = true

  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }

  reviewers {
    users = [
      data.github_user.current.id
    ]
  }
}

resource "github_actions_environment_variable" "dev_app_name" {
  repository    = var.github.repository
  environment   = github_repository_environment.dev.environment
  variable_name = "APP_NAME"
  value         = module.app_dev.name
}

resource "github_actions_environment_variable" "fakeprod_app_name" {
  repository    = var.github.repository
  environment   = github_repository_environment.fakeprod.environment
  variable_name = "APP_NAME"
  value         = module.app_fakeprod.name
}

resource "github_actions_environment_variable" "dev_rg" {
  repository    = var.github.repository
  environment   = github_repository_environment.dev.environment
  variable_name = "RESOURCE_GROUP_NAME"
  value         = data.azurerm_resource_group.rg.name
}

resource "github_actions_environment_variable" "fakeprod_rg" {
  repository    = var.github.repository
  environment   = github_repository_environment.fakeprod.environment
  variable_name = "RESOURCE_GROUP_NAME"
  value         = data.azurerm_resource_group.rg.name
}

resource "github_actions_environment_secret" "dev_client_id" {
  repository      = var.github.repository
  environment     = github_repository_environment.dev.environment
  secret_name     = "ARM_CLIENT_ID"
  plaintext_value = azurerm_user_assigned_identity.cd_dev.client_id
}

resource "github_actions_environment_secret" "fakeprod_client_id" {
  repository      = var.github.repository
  environment     = github_repository_environment.fakeprod.environment
  secret_name     = "ARM_CLIENT_ID"
  plaintext_value = azurerm_user_assigned_identity.cd_fakeprod.client_id
}

resource "github_actions_environment_secret" "dev_subscription_id" {
  repository      = var.github.repository
  environment     = github_repository_environment.dev.environment
  secret_name     = "ARM_SUBSCRIPTION_ID"
  plaintext_value = data.azurerm_subscription.current.subscription_id
}

resource "github_actions_environment_secret" "fakeprod_subscription_id" {
  repository      = var.github.repository
  environment     = github_repository_environment.fakeprod.environment
  secret_name     = "ARM_SUBSCRIPTION_ID"
  plaintext_value = data.azurerm_subscription.current.subscription_id
}

resource "github_actions_environment_secret" "dev_tenant_id" {
  repository      = var.github.repository
  environment     = github_repository_environment.dev.environment
  secret_name     = "ARM_TENANT_ID"
  plaintext_value = data.azurerm_subscription.current.tenant_id
}

resource "github_actions_environment_secret" "fakeprod_tenant_id" {
  repository      = var.github.repository
  environment     = github_repository_environment.fakeprod.environment
  secret_name     = "ARM_TENANT_ID"
  plaintext_value = data.azurerm_subscription.current.tenant_id
}
