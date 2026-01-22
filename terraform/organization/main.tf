resource "github_organization_custom_properties" "provider" {
  property_name = "provider"
  value_type    = "single_select"
  required      = false
  description   = "Target cloud provider"
  allowed_values = [
    "azure",
    "aws"
  ]
}

resource "github_organization_custom_properties" "terraform" {
  property_name = "terraform"
  value_type    = "true_false"
  required      = false
  description   = "Terraform landing zone"
}

#---------------------------------------------------------------------------------------------------
# TERRAFORM MODULE
#---------------------------------------------------------------------------------------------------
resource "github_repository" "terraform_module" {
  name       = "terraform-azurerm-resource-group"
  visibility = "private"
}

locals {
  path_terraform_module  = "${path.module}/repos/module"
  files_terraform_module = fileset(local.path_terraform_module, "**")
  file_paths_terraform_module = {
    for f in local.files_terraform_module : f => "${local.path_terraform_module}/${f}"
  }
}

resource "github_repository_file" "terraform_module" {
  for_each = local.file_paths_terraform_module

  repository = github_repository.terraform_module.name
  file       = each.key
  content    = file(each.value)
}

locals {
  issuer           = "https://token.actions.githubusercontent.com"
  sub_all_branches = "repo:${var.github_owner}/${github_repository.terraform_module.name}:ref:refs/heads/*"
  sub_main_branch  = "repo:${var.github_owner}/${github_repository.terraform_module.name}:ref:refs/heads/main"
  sub_pull_request = "repo:${var.github_owner}/${github_repository.terraform_module.name}:pull_request"
}

data "azurerm_client_config" "current" {}

resource "azuread_application_registration" "terraform_module" {
  display_name = "app-terraform-module"
}

resource "azuread_service_principal" "terraform_module" {
  client_id = azuread_application_registration.terraform_module.client_id
}

resource "azurerm_role_assignment" "terraform_module_contributor" {
  principal_id         = azuread_service_principal.terraform_module.object_id
  role_definition_name = "Contributor"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
}

resource "azurerm_role_assignment" "terraform_module_blob_contributor" {
  principal_id         = azuread_service_principal.terraform_module.object_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
}

resource "azuread_application_flexible_federated_identity_credential" "pull_request" {
  display_name               = "github-pull-request"
  application_id             = azuread_application_registration.terraform_module.id
  issuer                     = local.issuer
  audience                   = "api://AzureADTokenExchange"
  claims_matching_expression = "claims['sub'] eq '${local.sub_pull_request}'"
}

resource "github_actions_secret" "plan_azure_client_id" {
  repository      = github_repository.terraform_module.name
  secret_name     = "ARM_CLIENT_ID"
  plaintext_value = azuread_application_registration.terraform_module.client_id
}

resource "github_actions_secret" "azure_tenant_id" {
  repository      = github_repository.terraform_module.name
  secret_name     = "ARM_TENANT_ID"
  plaintext_value = data.azurerm_client_config.current.tenant_id
}

resource "github_actions_secret" "azure_subscription_id" {
  repository      = github_repository.terraform_module.name
  secret_name     = "ARM_SUBSCRIPTION_ID"
  plaintext_value = data.azurerm_client_config.current.subscription_id
}

#---------------------------------------------------------------------------------------------------
# TERRAFORM WORKFLOWS
#---------------------------------------------------------------------------------------------------
resource "github_repository" "terraform_workflows" {
  name       = "terraform-workflows"
  visibility = "private"
}

resource "github_actions_repository_access_level" "terraform_workflows" {
  access_level = "organization"
  repository   = github_repository.terraform_workflows.name
}

locals {
  path_terraform_workflows  = "${path.module}/repos/terraform"
  files_terraform_workflows = fileset(local.path_terraform_workflows, "**")
  file_paths_terraform_workflows = {
    for f in local.files_terraform_workflows : f => "${local.path_terraform_workflows}/${f}"
  }
}

resource "github_repository_file" "terraform_workflows" {
  for_each = local.file_paths_terraform_workflows

  repository = github_repository.terraform_workflows.name
  file       = each.key
  content    = file(each.value)
}

#---------------------------------------------------------------------------------------------------
# SENTINEL
#---------------------------------------------------------------------------------------------------
resource "github_repository" "sentinel_policies" {
  name       = "sentinel-policies"
  visibility = "public"
}

locals {
  path_sentinel_policies  = "${path.module}/repos/sentinel"
  files_sentinel_policies = fileset(local.path_sentinel_policies, "**")
  file_paths_sentinel_policies = {
    for f in local.files_sentinel_policies : f => "${local.path_sentinel_policies}/${f}"
  }
}

resource "github_repository_file" "sentinel_policies" {
  for_each = local.file_paths_sentinel_policies

  repository = github_repository.sentinel_policies.name
  file       = each.key
  content    = file(each.value)
}
