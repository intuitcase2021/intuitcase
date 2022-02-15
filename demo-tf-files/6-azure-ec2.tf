#creating NSG for azure VM
resource "azurerm_network_security_group" "az_nsg" {
  name                = "${var.az_nsg_name}"
  location            = "${azurerm_resource_group.az_rg.location}"
  resource_group_name = "${azurerm_resource_group.az_rg.name}"

  security_rule {
    name                       = "Port_22"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "24.98.94.109/32"
    destination_address_prefix = "*"
  }
}

#creating public IP for internet access to install packages
resource "azurerm_public_ip" "az_vm_public_ip" {
  name                = "${var.az_vm_public_ip_name}"
  resource_group_name = "${azurerm_resource_group.az_rg.name}"
  location            = "${azurerm_resource_group.az_rg.location}"
  allocation_method   = "Dynamic"
}

#creating azure nic to assign IP address to VM
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

#attaching SG to NIC
resource "azurerm_network_interface_security_group_association" "az_nsg_association" {
  network_interface_id      = azurerm_network_interface.az_vm_nic.id
  network_security_group_id = azurerm_network_security_group.az_nsg.id
}

#creating VM and attaching NIC
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

  provisioner "local-exec" {
    command = "cd ../ansible && ansible-playbook --private-key=~/.ssh/id_rsa -e 'instance_ip=${aws_instance.demo-private-instance}' python-aws-install-configure.yml"
  }

}
