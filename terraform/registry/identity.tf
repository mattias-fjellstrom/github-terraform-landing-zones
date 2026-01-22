resource "azurerm_user_assigned_identity" "function" {
  # name                = "id-terraform-registry-${random_string.suffix.result}"
  name                = "id-terraform-registry"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
}

# resource "azurerm_role_assignment" "monitoring_metrics_publisher" {
#   principal_id         = azurerm_user_assigned_identity.function.principal_id
#   scope                = azurerm_resource_group.default.id
#   role_definition_name = "Monitoring Metrics Publisher"
# }

resource "azurerm_role_assignment" "blob_contributor" {
  principal_id         = azurerm_user_assigned_identity.function.principal_id
  scope                = azurerm_storage_account.default.id
  role_definition_name = "Storage Blob Data Contributor"
}

# resource "azurerm_role_assignment" "storage_blob_owner" {
#   principal_id         = azurerm_user_assigned_identity.function.principal_id
#   scope                = azurerm_storage_account.default.id
#   role_definition_name = "Storage Blob Data Owner"
# }

# data "azurerm_cosmosdb_sql_role_definition" "contributor" {
#   resource_group_name = azurerm_resource_group.default.name
#   account_name        = azurerm_cosmosdb_account.terraform.name
#   role_definition_id  = "00000000-0000-0000-0000-000000000002"
# }

# resource "azurerm_cosmosdb_sql_role_assignment" "function_app" {
#   resource_group_name = data.azurerm_cosmosdb_sql_role_definition.contributor.resource_group_name
#   account_name        = data.azurerm_cosmosdb_sql_role_definition.contributor.account_name
#   role_definition_id  = data.azurerm_cosmosdb_sql_role_definition.contributor.id
#   scope               = azurerm_cosmosdb_account.terraform.id
#   principal_id        = azurerm_user_assigned_identity.function.principal_id
# }
