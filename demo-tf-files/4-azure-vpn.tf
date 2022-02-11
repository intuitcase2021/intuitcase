#creating azure localnetwork GW for tunnel 1
resource "azurerm_local_network_gateway" "az_local_nw_gw_tunnel1" {
  name                = "${var.az_local_nw_gw_tunnel1}"
  location            = "${azurerm_resource_group.az_rg.location}"
  resource_group_name = "${azurerm_resource_group.az_rg.name}"

  # AWS VPN Connection public IP address
  gateway_address = "${aws_vpn_connection.sitetositeVPN.tunnel1_address}"

  address_space = [
    # AWS VPC CIDR
    aws_vpc.demo-vpc.cidr_block
  ]
}

##creating azure network gateway connection for tunnel 1
resource "azurerm_virtual_network_gateway_connection" "az_virtual_gw_connection1_tunnel1" {
  name                = "${var.az_virtual_gw_connection1_tunnel1}"
  location            = "${azurerm_resource_group.az_rg.location}"
  resource_group_name = "${azurerm_resource_group.az_rg.name}"

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.az_virtual_nw_gw.id
  local_network_gateway_id   = azurerm_local_network_gateway.az_local_nw_gw_tunnel1.id
  shared_key = aws_vpn_connection.sitetositeVPN.tunnel1_preshared_key
}

##creating azure localnetwork GW for tunnel 1
resource "azurerm_local_network_gateway" "az_local_nw_gw_tunnel2" {
  name                = "${var.az_local_nw_gw_tunnel2}"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  gateway_address = "${aws_vpn_connection.sitetositeVPN.tunnel2_address}"

  address_space = [
    aws_vpc.demo-vpc.cidr_block
  ]
}

#creating azure network gateway connection for tunnel 1
resource "azurerm_virtual_network_gateway_connection" "az_virtual_gw_connection_tunnel2" {
  name                = "${var.az_virtual_gw_connection_tunnel2}"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.az_virtual_nw_gw.id
  local_network_gateway_id   = azurerm_local_network_gateway.az_local_nw_gw_tunnel2.id
  shared_key = aws_vpn_connection.sitetositeVPN.tunnel2_preshared_key
}
