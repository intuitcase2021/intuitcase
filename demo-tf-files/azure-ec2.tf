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

resource "azurerm_public_ip" "az_vm_public_ip" {
  name                = "${var.az_vm_public_ip_name}"
  resource_group_name = "${azurerm_resource_group.az_rg.name}"
  location            = "${azurerm_resource_group.az_rg.location}"
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "az_vm_nic" {
  name                = "${var.az_vm_nic}"
  location            = var.az_location
  resource_group_name = azurerm_resource_group.az_rg.name
  ip_configuration {
    name                          = "${var.az_vm_nic}-ip"
    subnet_id                     = azurerm_subnet.az_subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.az_vm_public_ip.id
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
    sku       = "18.04-LTS"
    version   = "latest"
  }

}
