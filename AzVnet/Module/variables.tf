provider "azurerm"{
version = "2.2.0"

  features {

  }
}

variable "az_resource_group_name"{
    default ="az-aws-vpn-rg"
}

variable "az_location" {
  default = "East US"
}
variable "az_vnet_name" {
  default = "az-aws-vpn-vnet"
}

variable "az_vnet_address_space" {
  default = "172.16.0.0/16"
}

variable "az_subnet_name"{
    default = "az-aws-subnet1"
}

variable "az_subnet_address_prefix"{
    default= "172.16.1.0/24"
}

variable "az_nsg_name" {
  default = "az-aws-nsg"
}

variable "az_security_name" {
  default = "az-aws-security"
}

variable "az_security_rule_tcp_name" {
  default = "az-aws-tcp-rule"
}

variable "az_security_rule_ssh_name" {
  default = "az-aws-ssh-name"
}

variable "az_security_rule_http_name" {
  default = "az-aws-http-rule"
}

variable "az_security_rule_https_name" {
  default = "az-aws-https-rule"
}

variable "az_vm_nic" {
  default = "az-vm-nic"
}

variable "az_vm" {
  default = "az-vm"
}

variable "az_local_nw_gw" {
  default = "az_local_nw_gw1"
}

variable "az_public_ip" {
  default = "az_public_ip"
}

variable "az_gw_subnet" {
  default = "GatewaySubnet"
}

variable "az_gw_subnet_address_prefix" {
  default = "172.16.0.0/24"
}

variable "az_virtual_nw_gw" {
  default = "az_virtual_nw_gw"
}

variable "aws_vpn_connection_tunnel1_address" {
  default = "53.22.58.160"
}

variable "aws_vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "az_local_nw_gw_tunnel1" {
  default = "az_local_nw_gw_tunnel1"
}

variable "aws_vpn_connection_tunnel1_preshared_key"{
  default = "XCVBNMJKILOYFD"
}

variable "az_virtual_gw_connection1_tunnel1" {
  default = "az_virtual_gw_connection_tunnel1"
}
variable "aws_vpn_connection_tunnel2_address" {
  default = "3.59.12.123"
}

variable "az_local_nw_gw_tunnel2" {
  default = "az_local_nw_gw_tunnel2"
}
variable "az_virtual_gw_connection_tunnel2" {
  default = "az_virtual_gw_connection_tunnel2"
}

variable "aws_vpn_connection_tunnel2_preshared_key" {
  default = "CVBGHJYUIKLK"
}