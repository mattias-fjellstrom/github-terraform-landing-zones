terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "2.7.1"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }

    github = {
      source  = "integrations/github"
      version = "~> 6.9.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.8.0"
    }
  }
}

provider "azurerm" {
  features {}
  storage_use_azuread = true
  subscription_id     = var.azure_subscription_id
}

provider "github" {
  owner = var.github_owner
}
