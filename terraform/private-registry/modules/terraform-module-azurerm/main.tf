resource "github_repository" "default" {
  name        = "terraform-${var.namespace}-${var.name}-${var.system}"
  description = "GitHub landing zone for a Terraform module"

  visibility = "public"

  has_discussions = false
  has_downloads   = false
  has_projects    = false
  has_wiki        = false

  topics = [
    "terraform",
    "module",
    "azure",
  ]
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

  lifecycle {
    ignore_changes = [
      content,
    ]
  }
}

resource "github_actions_variable" "module_registry_protocol_url" {
  repository    = github_repository.default.name
  variable_name = "MODULE_REGISTRY_PROTOCOL_URL"
  value         = var.module_registry_protocol_url
}

resource "github_actions_variable" "namespace" {
  repository    = github_repository.default.name
  variable_name = "NAMESPACE"
  value         = var.namespace
}

resource "github_actions_variable" "name" {
  repository    = github_repository.default.name
  variable_name = "NAME"
  value         = var.name
}

resource "github_actions_variable" "system" {
  repository    = github_repository.default.name
  variable_name = "SYSTEM"
  value         = var.system
}

resource "github_actions_secret" "azure_client_id" {
  repository      = github_repository.default.name
  secret_name     = "ARM_CLIENT_ID"
  plaintext_value = azuread_application_registration.apply.client_id
}

resource "github_actions_secret" "azure_tenant_id" {
  repository      = github_repository.default.name
  secret_name     = "ARM_TENANT_ID"
  plaintext_value = data.azurerm_client_config.current.tenant_id
}

resource "github_actions_secret" "azure_subscription_id" {
  repository      = github_repository.default.name
  secret_name     = "ARM_SUBSCRIPTION_ID"
  plaintext_value = data.azurerm_client_config.current.subscription_id
}
