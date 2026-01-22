resource "azurerm_log_analytics_workspace" "default" {
  name                = "log-terraform-registry-${random_string.suffix.result}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "function" {
  name                          = "appi-terraform-registry-${random_string.suffix.result}"
  location                      = azurerm_resource_group.default.location
  resource_group_name           = azurerm_resource_group.default.name
  application_type              = "web"
  workspace_id                  = azurerm_log_analytics_workspace.default.id
  local_authentication_disabled = true
}

resource "azurerm_storage_account" "default" {
  # name                            = "stterraformregistry${random_string.suffix.result}"
  name                            = "stterraform${random_string.suffix.result}"
  resource_group_name             = azurerm_resource_group.default.name
  location                        = azurerm_resource_group.default.location
  account_replication_type        = "LRS"
  account_tier                    = "Standard"
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true
}

resource "azurerm_storage_container" "deployments" {
  name                  = "deployments"
  storage_account_id    = azurerm_storage_account.default.id
  container_access_type = "private"
}

resource "azurerm_service_plan" "default" {
  # name                = "asp-terraform-registry-${random_string.suffix.result}"
  name                = "plan-terraform-registry"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku_name            = "FC1"
  os_type             = "Linux"
}

resource "azurerm_function_app_flex_consumption" "default" {
  name                = "func-terraform-registry-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  service_plan_id     = azurerm_service_plan.default.id

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.function.id
    ]
  }

  storage_container_type            = "blobContainer"
  storage_authentication_type       = "UserAssignedIdentity"
  storage_container_endpoint        = "${azurerm_storage_account.default.primary_blob_endpoint}${azurerm_storage_container.deployments.name}"
  storage_user_assigned_identity_id = azurerm_user_assigned_identity.function.id

  runtime_name           = "python"
  runtime_version        = "3.13"
  maximum_instance_count = 50
  instance_memory_in_mb  = 2048

  site_config {}

  app_settings = {
    COSMOS_DATABASE_NAME  = azurerm_cosmosdb_sql_database.registry.name
    COSMOS_CONTAINER_NAME = azurerm_cosmosdb_sql_container.modules.name

    AzureWebJobsStorage__credential  = "managedidentity"
    AzureWebJobsStorage__clientId    = azurerm_user_assigned_identity.function.client_id
    AzureWebJobsStorage__accountName = azurerm_storage_account.default.name

    CosmosDBConnection = azurerm_cosmosdb_account.terraform.primary_sql_connection_string
    # CosmosDBConnection__credential      = "managedidentity"
    # CosmosDBConnection__clientId        = azurerm_user_assigned_identity.function.client_id
    # CosmosDBConnection__accountEndpoint = azurerm_cosmosdb_account.terraform.endpoint

    APPLICATIONINSIGHTS_AUTHENTICATION_STRING = "Authorization=AAD;ClientId=${azurerm_user_assigned_identity.function.client_id}"
  }
}

resource "archive_file" "deployment" {
  type             = "zip"
  output_path      = "${path.module}/package/deployment-package.zip"
  source_dir       = "${path.module}/src"
  excludes         = ["${path.module}/src/.venv"]
  output_file_mode = "0666"
}

resource "terraform_data" "deployment" {
  provisioner "local-exec" {
    on_failure  = continue
    working_dir = "${path.module}/"
    command     = <<-AZCLI
      az functionapp deployment source config-zip \
        --src ${archive_file.deployment.output_path} \
        --name ${azurerm_function_app_flex_consumption.default.name} \
        --resource-group ${azurerm_resource_group.default.name} \
        --build-remote true
    AZCLI
  }

  depends_on = [
    azurerm_storage_container.deployments,
    azurerm_function_app_flex_consumption.default,
    azurerm_role_assignment.blob_contributor,
    azurerm_user_assigned_identity.function,
  ]
}
