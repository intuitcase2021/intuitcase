variable "az_nsg_name" {
  default = "demo-aws-nsg"
  type        = string
  description = "Name of the nsg"
}

variable "az_vm_nic" {
  default = "demo-vm-nic"
  type        = string
  description = "Name of the nic"
}

variable "az_vm_public_ip_name"{
  default = "demo-vm-public-ip"
  type        = string
  description = "Name of the public ip"
}

variable "az_vm" {
  default = "demo-vm"
  type        = string
  description = "Name of the azure VM"
}
