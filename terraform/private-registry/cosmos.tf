resource "azurerm_cosmosdb_account" "terraform" {
  name                = "cosno-terraform-registry-${random_string.suffix.result}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    failover_priority = 0
    location          = azurerm_resource_group.default.location
    zone_redundant    = false
  }
}

resource "azurerm_cosmosdb_sql_database" "registry" {
  name                = "cosmos-terraform-registry-${random_string.suffix.result}"
  account_name        = azurerm_cosmosdb_account.terraform.name
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_cosmosdb_sql_container" "modules" {
  name                  = "modules"
  resource_group_name   = azurerm_resource_group.default.name
  account_name          = azurerm_cosmosdb_account.terraform.name
  database_name         = azurerm_cosmosdb_sql_database.registry.name
  partition_key_kind    = "MultiHash"
  partition_key_paths   = ["/namespace", "/name", "/system"]
  partition_key_version = 2
}
