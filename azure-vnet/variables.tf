#azure variables

variable "az_rg_name"{
    default ="demo-az-rg"
}

variable "az_location" {
  default = "East US"
}
variable "az_vnet_name" {
  default = "az-aws-vpn-vnet"
}

variable "az_vnet_cidr" {
  default = "172.16.0.0/16"
}

variable "az_subnet_name"{
    default = "demo-subnet1"
}

variable "az_subnet_cidr"{
    default= "172.16.0.0/24"
}

variable "az_gw_subnet_name" {
  default = "GatewaySubnet"
}

variable "az_gw_subnet_cidr" {
  default = "172.16.1.0/24"
}

variable "az_public_ip_name" {
  default = "demo_public_ip"
}

variable "az_virtual_nw_gw_name" {
  default = "demo_virtual_nw_gw"
}






variable "az_local_nw_gw" {
  default = "az_local_nw_gw1"
}

variable "az_local_nw_gw_tunnel1" {
  default = "demo_local_nw_gw_tunnel1"
}

variable "az_virtual_gw_connection1_tunnel1" {
  default = "demo_virtual_gw_connection_tunnel1"
}

variable "az_local_nw_gw_tunnel2" {
  default = "demo_local_nw_gw_tunnel2"
}
variable "az_virtual_gw_connection_tunnel2" {
  default = "demo_virtual_gw_connection_tunnel2"
}




#aws variables


variable "name" {
  default     = "Default"
  type        = string
  description = "Name of the VPC"
}

variable "project" {
  default     = "Intuitcasestudy"
  type        = string
  description = "Name of project this VPC is meant to house"
}

variable "region" {
  default     = "us-east-1"
  type        = string
  description = "Region of the VPC"
}

variable "cidr_block" {
  default     = "192.168.0.0/16"
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr_blocks" {
  default     = ["192.168.0.0/24"]
  type        = list
  description = "List of public subnet CIDR blocks"
}

variable "private_subnet_cidr_blocks" {
  default     = ["192.168.1.0/24"]
  type        = list
  description = "List of private subnet CIDR blocks"
}

variable "availability_zones" {
  default     = ["us-east-1a", "us-east-1b"]
  type        = list
  description = "List of availability zones"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Extra tags to attach to the VPC resources"
}
