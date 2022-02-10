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

variable "ami" {
  default     = "ami-034508d5026c5bc94"
  type        = string
  description = "Amazon Machine Image (AMI) ID"
}

variable "key_name" {
  default     = "aws-vm-tk"
  type        = string
  description = "EC2 Key pair name for ssh"
}
