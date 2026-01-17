resource "github_repository" "default" {
  name        = var.name
  description = "GitHub landing zone for Terraform/Azure"

  visibility = "private"

  has_discussions = false
  has_downloads   = false
  has_projects    = false
  has_wiki        = false

  topics = [
    "azure",
    "terraform"
  ]
}

resource "github_repository_custom_property" "provider" {
  repository     = github_repository.default.name
  property_name  = "provider"
  property_type  = "string"
  property_value = ["azure"]
}

resource "github_repository_custom_property" "terraform" {
  repository     = github_repository.default.name
  property_name  = "terraform"
  property_type  = "true_false"
  property_value = ["true"]
}

locals {
  path       = "${path.module}/files"
  files      = fileset(local.path, "**")
  file_paths = { for f in local.files : f => "${local.path}/${f}" }
}

resource "github_repository_file" "all" {
  for_each   = local.file_paths
  repository = github_repository.default.name
  file       = each.key
  content    = file(each.value)
}

resource "github_repository_file" "backend" {
  repository = github_repository.default.name
  file       = "backend.tf"
  content    = var.state_backend
}

resource "github_actions_secret" "apply_azure_client_id" {
  repository      = github_repository.default.name
  secret_name     = "APPLY_AZURE_CLIENT_ID"
  plaintext_value = azuread_application_registration.apply.client_id
}

resource "github_actions_secret" "plan_azure_client_id" {
  repository      = github_repository.default.name
  secret_name     = "PLAN_AZURE_CLIENT_ID"
  plaintext_value = azuread_application_registration.plan.client_id
}

resource "github_actions_secret" "azure_tenant_id" {
  repository      = github_repository.default.name
  secret_name     = "AZURE_TENANT_ID"
  plaintext_value = data.azurerm_client_config.current.tenant_id
}

resource "github_actions_secret" "azure_subscription_id" {
  repository      = github_repository.default.name
  secret_name     = "AZURE_SUBSCRIPTION_ID"
  plaintext_value = data.azurerm_client_config.current.subscription_id
}
