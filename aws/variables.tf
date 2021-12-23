variable "name" {
  default     = "Default"
  type        = string
  description = "Name of the VPC"
}

variable "project" {
  type        = string
  description = "Name of project this VPC is meant to house"
}

variable "environment" {
  type        = string
  description = "Name of environment this VPC is targeting"
}

variable "region" {
  default     = "us-east-1"
  type        = string
  description = "Region of the VPC"
}

variable "key_name" {
  type        = string
  description = "EC2 Key pair name for ssh"
}

variable "cidr_block" {
  default     = "10.0.0.0/16"
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr_blocks" {
  default     = ["10.0.0.0/24"]
  type        = list
  description = "List of public subnet CIDR blocks"
}

variable "private_subnet_cidr_blocks" {
  default     = ["10.0.1.0/24"]
  type        = list
  description = "List of private subnet CIDR blocks"
}

variable "availability_zones" {
  default     = ["us-east-1a", "us-east-1b"]
  type        = list
  description = "List of availability zones"
}

variable "ami" {
  type        = string
  description = "Amazon Machine Image (AMI) ID"
}

variable "ebs_optimized" {
  default     = false
  type        = bool
  description = "If true, the  instance will be EBS-optimized"
}

variable "instance_type" {
  default     = "t3.nano"
  type        = string
  description = "Instance type for  instance"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Extra tags to attach to the VPC resources"
}
