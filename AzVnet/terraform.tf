terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state"
    storage_account_name = "terraformtj"
    container_name       = "tfstate"
    key                  = "az-testcase.tfstate"
  }
}