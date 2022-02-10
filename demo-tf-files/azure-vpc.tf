# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "5c664240-69c2-46a7-b12f-476b1e353d7f"
}

resource "azurerm_resource_group" "az_rg" {
  name     = "${var.az_rg_name}"
  location = "${var.az_location}"
}
resource "azurerm_virtual_network" "az_vnet" {
  name                = "${var.az_vnet_name}"
  location            = "${azurerm_resource_group.az_rg.location}"
  resource_group_name = "${azurerm_resource_group.az_rg.name}"
  address_space       = ["${var.az_vnet_cidr}"]

  tags = {
    environment = "test"
  }
}

resource "azurerm_subnet" "az_subnet" {
  name                 = "${var.az_subnet_name}"
  resource_group_name  = "${azurerm_resource_group.az_rg.name}"
  virtual_network_name = "${azurerm_virtual_network.az_vnet.name}"
  address_prefix     = "${var.az_subnet_cidr}"
}

resource "azurerm_subnet" "az_gw_subnet" {
  name                 = "${var.az_gw_subnet_name}"
  resource_group_name  = "${azurerm_resource_group.az_rg.name}"
  virtual_network_name = "${azurerm_virtual_network.az_vnet.name}"
  address_prefix       = "${var.az_gw_subnet_cidr}"
}

resource "azurerm_public_ip" "az_public_ip" {
  name                = "${var.az_public_ip_name}"
  resource_group_name = "${azurerm_resource_group.az_rg.name}"
  location            = "${azurerm_resource_group.az_rg.location}"
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "az_virtual_nw_gw" {
  name                = "${var.az_virtual_nw_gw_name}"
  location            = "${azurerm_resource_group.az_rg.location}"
  resource_group_name = "${azurerm_resource_group.az_rg.name}"

  type     = "Vpn"
  vpn_type = "RouteBased"

 active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "${azurerm_public_ip.az_public_ip.name}"
    public_ip_address_id          = "${azurerm_public_ip.az_public_ip.id}"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "${azurerm_subnet.az_gw_subnet.id}"
  }
}
