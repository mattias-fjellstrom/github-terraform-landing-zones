locals {
  issuer           = "https://token.actions.githubusercontent.com"
  sub_pull_request = "repo:${var.github_owner}/${github_repository.default.name}:pull_request"
}

data "azurerm_client_config" "current" {}

resource "azuread_application_registration" "apply" {
  display_name = "terraform-module-${var.namespace}-${var.name}-${var.system}"
}

resource "azuread_service_principal" "apply" {
  client_id = azuread_application_registration.apply.client_id
}

resource "azurerm_role_assignment" "contributor" {
  principal_id         = azuread_service_principal.apply.object_id
  role_definition_name = "Contributor"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
}

resource "azurerm_role_assignment" "blob_contributor" {
  principal_id         = azuread_service_principal.apply.object_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
}

resource "azuread_application_flexible_federated_identity_credential" "pull_request" {
  display_name               = "github-pull-request"
  application_id             = azuread_application_registration.apply.id
  issuer                     = local.issuer
  audience                   = "api://AzureADTokenExchange"
  claims_matching_expression = "claims['sub'] eq '${local.sub_pull_request}'"
}
