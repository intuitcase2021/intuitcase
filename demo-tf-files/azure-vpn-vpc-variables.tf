#azure variables

variable "az_rg_name"{
    default ="demo-az-rg"
    type        = string
    description = "Name of the resource group"
}

variable "az_location" {
  default = "East US"
  type        = string
  description = "Name of the Region"
}

variable "az_vnet_name" {
  default = "az-aws-vpn-vnet"
  type        = string
  description = "Name of the vnet"
}

variable "az_vnet_cidr" {
  default = "172.16.0.0/16"
  type        = string
  description = "Vnet cidr_block"
}

variable "az_subnet_name"{
    default = "demo-subnet1"
    type        = string
    description = "Name of the subnet"
}

variable "az_subnet_cidr"{
    default= "172.16.0.0/24"
    type        = string
    description = "subnet cidr_block"
}

variable "az_gw_subnet_name" {
  default = "GatewaySubnet"
  type        = string
  description = "name of the GatewaySubnet"
}

variable "az_gw_subnet_cidr" {
  default = "172.16.1.0/24"
  type        = string
  description = "GatewaySubnet cidr_block"
}

variable "az_public_ip_name" {
  default = "demo_public_ip"
  type        = string
  description = "Name of the public IP"
}

variable "az_virtual_nw_gw_name" {
  default = "demo_virtual_nw_gw"
  type        = string
  description = "Name of the virtual network gateway"
}


variable "az_local_nw_gw_tunnel1" {
  default = "demo_local_nw_gw_tunnel1"
  type        = string
  description = "Name of the tuneel 1"
}

variable "az_virtual_gw_connection1_tunnel1" {
  default = "demo_virtual_gw_connection_tunnel1"
  type        = string
  description = "Name of the virtaul conenction tunnel 1"
}

variable "az_local_nw_gw_tunnel2" {
  default = "demo_local_nw_gw_tunnel2"
  type        = string
  description = "Name of the local gateway tunnel 2"
}
variable "az_virtual_gw_connection_tunnel2" {
  default = "demo_virtual_gw_connection_tunnel2"
  type        = string
  description = "Name of conencton 2"
}
