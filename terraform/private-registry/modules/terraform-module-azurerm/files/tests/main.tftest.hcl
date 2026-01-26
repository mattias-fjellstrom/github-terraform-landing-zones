variables {
  # add variables
}

provider "azurerm" {
  features {}
}

run "should_plan" {
  command = plan
}