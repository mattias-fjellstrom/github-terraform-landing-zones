resource "github_repository" "default" {
  name        = var.name
  description = "GitHub landing zone for Terraform/AWS"

  has_discussions = false
  has_downloads   = false
  has_projects    = false
  has_wiki        = false

  topics = [
    "aws",
    "terraform"
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
}

resource "github_repository_file" "backend" {
  repository = github_repository.default.name
  file       = "backend.tf"
  content    = var.state_backend
}

resource "github_actions_secret" "main_aws_iam_role_arn" {
  repository      = github_repository.default.name
  secret_name     = "MAIN_AWS_IAM_ROLE_ARN"
  plaintext_value = aws_iam_role.main.arn
}

resource "github_actions_secret" "all_aws_iam_role_arn" {
  repository      = github_repository.default.name
  secret_name     = "ALL_AWS_IAM_ROLE_ARN"
  plaintext_value = aws_iam_role.all.arn
}
