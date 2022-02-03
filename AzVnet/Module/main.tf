resource "azurerm_resource_group" "az_rg" {
  name     = "${var.az_resource_group_name}"
  location = "${var.az_location}"
}
resource "azurerm_virtual_network" "az_vnet" {
  name                = "${var.az_vnet_name}"
  location            = "${azurerm_resource_group.az_rg.location}"
  resource_group_name = "${azurerm_resource_group.az_rg.name}"
  address_space       = ["${var.az_vnet_address_space}"]

  tags = {
    environment = "test"
  }
}

resource "azurerm_subnet" "az_subnet" {
  name                 = "${var.az_subnet_name}"
  resource_group_name  = "${azurerm_resource_group.az_rg.name}"
  virtual_network_name = "${azurerm_virtual_network.az_vnet.name}"
  address_prefix     = "${var.az_subnet_address_prefix}"
}

resource "azurerm_subnet" "az_gw_subnet" {
  name                 = "${var.az_gw_subnet}"
  resource_group_name  = "${azurerm_resource_group.az_rg.name}"
  virtual_network_name = "${azurerm_virtual_network.az_vnet.name}"
  address_prefix       = "${var.az_gw_subnet_address_prefix}"
}

resource "azurerm_public_ip" "az_public_ip" {
  name                = "${var.az_public_ip}"
  resource_group_name = "${azurerm_resource_group.az_rg.name}"
  location            = "${azurerm_resource_group.az_rg.location}"
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "az_virtual_nw_gw" {
  name                = "${var.az_virtual_nw_gw}"
  location            = "${azurerm_resource_group.az_rg.location}"
  resource_group_name = "${azurerm_resource_group.az_rg.name}"

  type     = "Vpn"
  vpn_type = "RouteBased"

  # This might me expensive, check the prices  
 active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = azurerm_public_ip.az_public_ip.name
    public_ip_address_id          = azurerm_public_ip.az_public_ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.az_gw_subnet.id
  }
}


resource "azurerm_network_security_group" "az_nsg" {
  name                = "${var.az_nsg_name}"
  location            = "${azurerm_resource_group.az_rg.location}"
  resource_group_name = "${azurerm_resource_group.az_rg.name}"

  security_rule {
    name                       = "${var.az_security_rule_tcp_name}"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "${var.az_security_rule_ssh_name}"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "${var.az_security_rule_http_name}"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "80"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "${var.az_security_rule_https_name}"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "443"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "az_vm_nic" {
  name                = "${var.az_vm_nic}"
  location            = var.az_location
  resource_group_name = azurerm_resource_group.az_rg.name
  ip_configuration {
    name                          = "${var.az_vm_nic}-ip"
    subnet_id                     = azurerm_subnet.az_subnet.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "az_nsg_association" {
  network_interface_id      = azurerm_network_interface.az_vm_nic.id
  network_security_group_id = azurerm_network_security_group.az_nsg.id
}


resource "azurerm_linux_virtual_machine" "az_vm" {
  name                  = var.az_vm
  resource_group_name   = azurerm_resource_group.az_rg.name
  location              = var.az_location
  network_interface_ids = [azurerm_network_interface.az_vm_nic.id]
  size                  = "Standard_B1s"
  admin_username      = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

}

resource "azurerm_local_network_gateway" "az_local_nw_gw_tunnel1" {
  name                = "${var.az_local_nw_gw_tunnel1}"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name

  # AWS VPN Connection public IP address
  gateway_address = var.aws_vpn_connection_tunnel1_address

  address_space = [
    # AWS VPC CIDR
    var.aws_vpc_cidr_block
  ]
}

resource "azurerm_virtual_network_gateway_connection" "az_virtual_gw_connection1_tunnel1" {
  name                = "${var.az_virtual_gw_connection1_tunnel1}"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.az_virtual_nw_gw.id
  local_network_gateway_id   = azurerm_local_network_gateway.az_local_nw_gw_tunnel1.id

  # AWS VPN Connection secret shared key
  shared_key = var.aws_vpn_connection_tunnel1_preshared_key
}

# Tunnel from Azure to AWS vpn_connection_1 (tunnel2)
resource "azurerm_local_network_gateway" "az_local_nw_gw_tunnel2" {
  name                = "${var.az_local_nw_gw_tunnel2}"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name

  gateway_address = var.aws_vpn_connection_tunnel2_address

  address_space = [
    var.aws_vpc_cidr_block
  ]
}

resource "azurerm_virtual_network_gateway_connection" "az_virtual_gw_connection_tunnel2" {
  name                = "${var.az_virtual_gw_connection_tunnel2}"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.az_virtual_nw_gw.id
  local_network_gateway_id   = azurerm_local_network_gateway.az_local_nw_gw_tunnel2.id

  shared_key = var.aws_vpn_connection_tunnel2_preshared_key
}





