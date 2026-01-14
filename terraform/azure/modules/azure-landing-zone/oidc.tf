locals {
  issuer           = "https://token.actions.githubusercontent.com"
  sub_all_branches = "repo:${var.github_owner}/${github_repository.default.name}:ref:refs/heads/*"
  sub_main_branch  = "repo:${var.github_owner}/${github_repository.default.name}:ref:refs/heads/main"
  sub_pull_request = "repo:${var.github_owner}/${github_repository.default.name}:pull_request"
}

#---------------------------------------------------------------------------------------------------
# AZURE
#---------------------------------------------------------------------------------------------------
data "azurerm_client_config" "current" {}

resource "azuread_application_registration" "apply" {
  display_name = "app-apply-${var.name}"
}

resource "azuread_service_principal" "apply" {
  client_id = azuread_application_registration.apply.client_id
}

resource "azurerm_role_assignment" "apply_contributor" {
  principal_id         = azuread_service_principal.apply.object_id
  role_definition_name = "Contributor"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
}

moved {
  from = azurerm_role_assignment.apply
  to   = azurerm_role_assignment.apply_contributor
}

resource "azurerm_role_assignment" "apply_blob_contributor" {
  principal_id         = azuread_service_principal.apply.object_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
}

resource "azuread_application_flexible_federated_identity_credential" "main_branch" {
  display_name               = "github-main-branch"
  application_id             = azuread_application_registration.apply.id
  issuer                     = local.issuer
  audience                   = "api://AzureADTokenExchange"
  claims_matching_expression = "claims['sub'] eq '${local.sub_main_branch}'"
}

resource "azuread_application_registration" "plan" {
  display_name = "app-plan-${var.name}"
}

resource "azuread_service_principal" "plan" {
  client_id = azuread_application_registration.plan.client_id
}

resource "azurerm_role_assignment" "plan_reader" {
  principal_id         = azuread_service_principal.plan.object_id
  role_definition_name = "Reader"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
}

moved {
  from = azurerm_role_assignment.plan
  to   = azurerm_role_assignment.plan_reader
}

resource "azurerm_role_assignment" "plan_blob_contributor" {
  principal_id         = azuread_service_principal.plan.object_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
}

moved {
  from = azurerm_role_assignment.blob
  to   = azurerm_role_assignment.plan_blob_contributor
}

resource "azuread_application_flexible_federated_identity_credential" "all_branches" {
  display_name               = "github-all-branches"
  application_id             = azuread_application_registration.plan.id
  issuer                     = local.issuer
  audience                   = "api://AzureADTokenExchange"
  claims_matching_expression = "claims['sub'] matches '${local.sub_all_branches}'"
}

resource "azuread_application_flexible_federated_identity_credential" "pull_request" {
  display_name               = "github-pull-request"
  application_id             = azuread_application_registration.plan.id
  issuer                     = local.issuer
  audience                   = "api://AzureADTokenExchange"
  claims_matching_expression = "claims['sub'] eq '${local.sub_pull_request}'"
}
