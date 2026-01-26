resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_resource_group" "default" {
  name     = "rg-terraform-registry-${random_string.suffix.result}"
  location = var.azure_location
}
