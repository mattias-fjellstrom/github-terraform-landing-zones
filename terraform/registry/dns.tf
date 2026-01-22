data "azurerm_dns_zone" "registry" {
  name                = var.azure_dns_zone_name
  resource_group_name = var.azure_dns_resource_group_name
}

resource "azurerm_dns_cname_record" "cname" {
  name                = "registry"
  zone_name           = var.azure_dns_zone_name
  resource_group_name = var.azure_dns_resource_group_name
  ttl                 = 3600
  record              = azurerm_function_app_flex_consumption.default.default_hostname
}

resource "azurerm_dns_txt_record" "verification" {
  name                = "asuid.registry"
  zone_name           = var.azure_dns_zone_name
  resource_group_name = var.azure_dns_resource_group_name
  ttl                 = 3600

  record {
    value = azurerm_function_app_flex_consumption.default.custom_domain_verification_id
  }
}

resource "azurerm_app_service_custom_hostname_binding" "registry" {
  app_service_name    = azurerm_function_app_flex_consumption.default.name
  resource_group_name = azurerm_resource_group.default.name
  hostname            = "${azurerm_dns_cname_record.cname.name}.${var.azure_dns_zone_name}"

  depends_on = [azurerm_dns_txt_record.verification]
}

resource "azurerm_app_service_managed_certificate" "registry" {
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.registry.id
}

resource "azurerm_app_service_certificate_binding" "registry" {
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.registry.id
  certificate_id      = azurerm_app_service_managed_certificate.registry.id
  ssl_state           = "SniEnabled"
}
