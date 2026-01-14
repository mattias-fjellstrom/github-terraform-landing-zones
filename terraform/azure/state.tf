resource "azurerm_resource_group" "default" {
  name     = "rg-github-terraform-landing-zones"
  location = var.azure_location
}

resource "random_string" "suffix" {
  length  = 10
  special = false
  upper   = false
}

resource "azurerm_storage_account" "state" {
  name                     = "tfstate${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.default.name
  location                 = azurerm_resource_group.default.location
  account_replication_type = "LRS"
  account_tier             = "Standard"
}

resource "azurerm_storage_container" "state" {
  name               = "state"
  storage_account_id = azurerm_storage_account.state.id
}
