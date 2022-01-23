provider "aws" {
  region = var.region
}

resource "aws_vpc" "demo-vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name        = "demo-vpc",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_internet_gateway" "demo-IGW" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = merge(
    {
      Name        = "demo-IGW",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_subnet" "publicSN" {
  count = length(var.public_subnet_cidr_blocks)

  vpc_id                  = aws_vpc.demo-vpc.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name        = "PublicSN",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = merge(
    {
      Name        = "PublicRT",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.publicRT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.demo-IGW.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr_blocks)

  subnet_id      = aws_subnet.publicSN[count.index].id
  route_table_id = aws_route_table.publicRT.id
}



resource "aws_eip" "nat" {
  count = length(var.public_subnet_cidr_blocks)

  vpc = true

  tags = {
    Name = "demo-eip"
  }
}

resource "aws_nat_gateway" "demo-NATGW" {
  depends_on = [aws_internet_gateway.demo-IGW]

  count = length(var.public_subnet_cidr_blocks)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.publicSN[count.index].id

  tags = merge(
    {
      Name        = "gwNAT",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_subnet" "privateSN" {
  count = length(var.private_subnet_cidr_blocks)

  vpc_id            = aws_vpc.demo-vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name        = "PrivateSN",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_route_table" "PrivateRT" {
  count = length(var.private_subnet_cidr_blocks)

  vpc_id = aws_vpc.demo-vpc.id

  tags = merge(
    {
      Name        = "PrivateRT",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_route" "Private" {
  count = length(var.private_subnet_cidr_blocks)

  route_table_id         = aws_route_table.PrivateRT[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.demo-NATGW[count.index].id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr_blocks)

  subnet_id      = aws_subnet.privateSN[count.index].id
  route_table_id = aws_route_table.PrivateRT[count.index].id
}


resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh-key" {
  key_name   = var.key_name
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { 
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./demo-ssh-key.pem && sleep 5 && chmod 400 ./demo-ssh-key.pem && ssh-add ./demo-ssh-key.pem"
  }
}


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
  associate_public_ip_address = true

  tags = merge(
    {
      Name        = "Bastion",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_network_interface_sg_attachment" "bastion" {
  security_group_id    = aws_security_group.bastion-SG.id
  network_interface_id = aws_instance.bastion.primary_network_interface_id
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

resource "aws_instance" "demo-private-instance" {
  ami                         = var.ami
  availability_zone           = var.availability_zones[0]
  ebs_optimized               = var.ebs_optimized
  instance_type               = var.instance_type
  key_name                    = var.key_name
  monitoring                  = true
  subnet_id                   = aws_subnet.privateSN[0].id
  associate_public_ip_address = true



  tags = merge(
    {
      Name        = "demo-private-instance",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_network_interface_sg_attachment" "private-SG" {
  security_group_id    = aws_security_group.private-SG.id
  network_interface_id = aws_instance.demo-private-instance.primary_network_interface_id
}