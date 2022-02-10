provider "aws" {
  region = var.region
}

data "azurerm_public_ip" "azure_public_ip" {
  name                = "${azurerm_public_ip.az_public_ip.name}"
  resource_group_name = "${azurerm_resource_group.az_rg.name}"
}

resource "aws_customer_gateway" "demo-customerGW" {
  bgp_asn    = 65000
  ip_address = "${data.azurerm_public_ip.azure_public_ip.ip_address}"
  type       = "ipsec.1"

  tags = {
    Name = "demo-customer-gateway"
  }
}


resource "aws_vpn_gateway" "demo-VPG" {
  vpc_id          = aws_vpc.demo-vpc.id

  tags = {
    Name = "demo-VPG"
  }
}


resource "aws_vpn_gateway_attachment" "demo-vpn_attachment" {
  vpc_id         = aws_vpc.demo-vpc.id
  vpn_gateway_id = aws_vpn_gateway.demo-VPG.id
}

resource "aws_vpn_gateway_route_propagation" "demo-route-propagation" {
  vpn_gateway_id = aws_vpn_gateway.demo-VPG.id
  route_table_id = aws_route_table.publicRT.id
  timeouts {
      create = "5m"
  }
}

resource "aws_vpn_gateway_route_propagation" "demo-route-propagation-privateRT" {
  vpn_gateway_id = aws_vpn_gateway.demo-VPG.id
  route_table_id = aws_route_table.PrivateRT.id
  timeouts {
      create = "5m"
  }
}

resource "aws_vpn_connection" "sitetositeVPN" {
  vpn_gateway_id           = aws_vpn_gateway.demo-VPG.id
  customer_gateway_id      = aws_customer_gateway.demo-customerGW.id
  type                     = "ipsec.1"
  static_routes_only       = true


  tags = {
    Name = "demo-S2S-vpn"
  }

}

#static route in site2site vpn to customer/azure CIDR
resource "aws_vpn_connection_route" "azureVPN" {
  destination_cidr_block = "${azurerm_virtual_network.az_vnet.address_space[0]}"
  vpn_connection_id      = aws_vpn_connection.sitetositeVPN.id
}
