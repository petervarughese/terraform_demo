resource "azurerm_resource_group" "rg-peterv-mgmt" {
    name = "rg-peterv-mgmt"
    location = var.resource_group_location
}

resource "azurerm_resource_group" "rg-peterv-identity" {
    name = "rg-peterv-identity"
    location = var.resource_group_location
    }

  resource "azurerm_resource_group" "rg-peterv-network" {
  name = "rg-peterv-network"
  location = var.resource_group_location
  }

#Created security/network group
resource "azurerm_network_security_group" "peterv-security-group" {
  name                = "my_security_group"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg-peterv-network.name
}

resource "azurerm_virtual_network" "peterv-vn" {
  name                = "peterv-vn"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg-peterv-network.name
  address_space       = ["172.20.124.0/23"]
}

#Create Subnet
resource "azurerm_subnet" "peterv-subnet-bastion" {
  name                 = "peterv-subnet-bastion"
  resource_group_name  = azurerm_resource_group.rg-peterv-network.name
  virtual_network_name = azurerm_virtual_network.peterv-vn.name
  address_prefixes     = ["172.20.125.0/26"]
}

resource "azurerm_subnet" "peterv-subnet-gateway" {
  name                 = "peterv-subnet-gateway"
  resource_group_name  = azurerm_resource_group.rg-peterv-network.name
  virtual_network_name = azurerm_virtual_network.peterv-vn.name
  address_prefixes     = ["172.20.124.0/24"]
}

#Key Vaults
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "peterv-kv-mgmt" {
  name                       = "peterv-kv-mgmt"
  location                   = var.resource_group_location
  resource_group_name        = azurerm_resource_group.rg-peterv-mgmt.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
}


  resource "azurerm_key_vault" "peterv-kv-id" {
  name                       = "peterv-kv-id"
  location                   = var.resource_group_location
  resource_group_name        = azurerm_resource_group.rg-peterv-identity.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  }

#Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "my_log_analytics_workspace" {
  name                = "my-log-analytics-workspace"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg-peterv-mgmt.name
}

#Storage accounts
resource "azurerm_storage_account" "sa_mgmt" {
  name                     = "petervstoreage1234"
  resource_group_name      = azurerm_resource_group.rg-peterv-mgmt.name
  location                 = var.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_account" "sa_id" {
  name                     = "petervstoreage1235"
  resource_group_name      = azurerm_resource_group.rg-peterv-identity.name
  location                 = var.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

#Network Interfaces
resource "azurerm_network_interface" "bastion_nic" {
  name                = "bastion_nic"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg-peterv-mgmt.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.peterv-subnet-bastion.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "gateway_nic" {
  name                = "gateway_nic"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg-peterv-identity.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.peterv-subnet-gateway.id
    private_ip_address_allocation = "Dynamic"
  }
}
