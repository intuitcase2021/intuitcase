
#####
#create SG and bastion ec2 instance in public subnet
#####

resource "aws_security_group" "bastion-SG" {
  name   = "Bastion-SG"
  description = "allow ssh access on port 22 from local/my IP"
  vpc_id = aws_vpc.demo-vpc.id

  ingress {
    description = "ssh access"
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
      Name        = "Bastion-SG",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_instance" "bastion" {
  ami                         = var.ami
  availability_zone           = var.availability_zones[0]
  ebs_optimized               = var.ebs_optimized
  instance_type               = var.instance_type
  key_name                    = var.key_name
  monitoring                  = true
  subnet_id                   = aws_subnet.publicSN[0].id
  security_groups             = ["${aws_security_group.bastion-SG.id}"]
  associate_public_ip_address = true

  provisioner "local-exec" {
    command = "cd ../ansible && ansible-playbook -e 'public_ip=${aws_instance.bastion.public_ip}' ssh_config.yml"
  }

  tags = merge(
    {
      Name        = "Bastion",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}


#####
#create SG and ec2 instance in private subnet
#####
resource "aws_security_group" "private-SG" {
  name   = "private-SG"
  description = "allow ssh access on port 22 from bastion host"
  vpc_id = aws_vpc.demo-vpc.id

  ingress {
    description = "ssh access from bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.bastion-SG.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name        = "private-SG",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}
