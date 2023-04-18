terraform {
  required_version = ">= 0.14"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.48.0"
    }
  }

  #Replace values below for your resource group, storage account, container name, and file name (key):
  backend "azurerm" {
    resource_group_name  = "rg-terraform-launch"
    storage_account_name = "launchterraformstate"
    container_name       = "tfstate"
    key                  = "peterv.tfstate"
  }

}

provider "azurerm" {
  features {}
}
