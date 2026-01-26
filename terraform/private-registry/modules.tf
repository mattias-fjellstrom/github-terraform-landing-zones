locals {
  module_registry_protocol_url = join("",
    [
      "https://",
      azurerm_dns_cname_record.cname.name,
      ".",
      data.azurerm_dns_zone.registry.name,
      "/terraform/modules/v1/"
    ]
  )
}

module "azurerm_resource_group" {
  source = "./modules/terraform-module-azurerm"

  github_owner                 = var.github_owner
  module_registry_protocol_url = local.module_registry_protocol_url

  namespace = "umbrella-security"
  name      = "resource-group"
  system    = "azurerm"
}
