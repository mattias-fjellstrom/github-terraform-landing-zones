resource "azurerm_resource_group" "default" {
  name     = "rg-${var.name_suffix}"
  location = var.location
}
