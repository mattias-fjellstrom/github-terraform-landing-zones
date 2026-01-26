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
