#creating SG for bastion host
resource "aws_security_group" "bastion-SG" {
  name   = "demo-Bastion-SG"
  description = "allow ssh access on port 22 from local/my IP"
  vpc_id = aws_vpc.demo-vpc.id

  ingress {
    description = "ssh access from my local"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["24.98.94.109/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = merge(
    {
      Name        = "demo-Bastion-SG",
      Project     = var.project
    },
    var.tags
  )
}

#creating bastion ec2 isntace and attaching SG
resource "aws_instance" "bastion" {
  ami                         = var.ami
  availability_zone           = var.availability_zones[0]
  ebs_optimized               = var.ebs_optimized
  instance_type               = var.instance_type
  key_name                    = var.key_name
  monitoring                  = true
  subnet_id                   = aws_subnet.publicSN[0].id
  vpc_security_group_ids      = ["${aws_security_group.bastion-SG.id}"]
  associate_public_ip_address = true

  tags = merge(
    {
      Name        = "demo-Bastion",
      Project     = var.project
    },
    var.tags
  )
}


#####
#create SG and ec2 instance in private subnet
#####
resource "aws_security_group" "private-SG" {
  name   = "demo-private-SG"
  description = "allow ssh access on port 22 from bastion host"
  vpc_id = aws_vpc.demo-vpc.id

  ingress {
    description = "ssh access from bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.bastion-SG.id}"]
    #cidr_blocks  = ["${azurerm_linux_virtual_machine.az_vm.private_ip_address}/32"]
  }
  ingress {
    description = "ssh access through bastion SG"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = ["24.98.94.109/32"]
  }
  ingress {
    description = "allowing traffic with in vnet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = ["192.168.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name        = "demo-private-SG",
      Project     = var.project
    },
    var.tags
  )
}

#creating private instance 
resource "aws_instance" "demo-private-instance" {
  ami                         = var.ami
  availability_zone           = var.availability_zones[1]
  ebs_optimized               = var.ebs_optimized
  instance_type               = var.instance_type
  key_name                    = var.key_name
  monitoring                  = true
  subnet_id                   = aws_subnet.privateSN[0].id
  vpc_security_group_ids      = ["${aws_security_group.private-SG.id}"]
  associate_public_ip_address = false

  tags = merge(
    {
      Name        = "demo-private-instance",
      Project     = var.project
    },
    var.tags
  )
}
