resource "azurerm_user_assigned_identity" "function" {
  name                = "id-terraform-registry-${random_string.suffix.result}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_role_assignment" "blob_contributor" {
  principal_id         = azurerm_user_assigned_identity.function.principal_id
  scope                = azurerm_storage_account.default.id
  role_definition_name = "Storage Blob Data Contributor"
}
