resource "github_repository" "default" {
  name        = var.repository_name
  description = "Terraform landing zone"
}

# resource "github_repository_custom_property" "purpose" {
#   repository     = github_repository.default.name
#   property_name  = "purpose"
#   property_type  = "single_select"
#   property_value = ["landing-zone"]
# }

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
