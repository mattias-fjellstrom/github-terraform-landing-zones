terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.7.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.57.0"
    }

    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

provider "github" {
  owner = var.github_owner
}
