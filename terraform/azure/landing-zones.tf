module "happy_unicorn" {
  source = "./modules/azure-landing-zone"

  github_owner  = var.github_owner
  name          = "happy-unicorn"
  state_backend = <<-HCL
  terraform {
    backend "azurerm" {
      use_oidc             = true
      use_azuread_auth     = true
      storage_account_name = "${azurerm_storage_account.state.name}"
      container_name       = "${azurerm_storage_container.state.name}"
      key                  = "state/happy-unicorn/terraform.tfstate"
    }
  }
  HCL
}
