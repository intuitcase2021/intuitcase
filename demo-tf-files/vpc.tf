

resource "aws_vpc" "demo-vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name        = "demo-vpc",
      Project     = var.project
    },
    var.tags
  )
}

resource "aws_internet_gateway" "demo-IGW" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = merge(
    {
      Name        = "demo-IGW",
      Project     = var.project
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
      Name        = "demo-PublicSN",
      Project     = var.project
    },
    var.tags
  )
}

resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = merge(
    {
      Name        = "demo-PublicRT",
      Project     = var.project
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
      Name        = "demo-NatGW",
      Project     = var.project
    },
    var.tags
  )
}

resource "aws_subnet" "privateSN" {
  count = length(var.private_subnet_cidr_blocks)

  vpc_id            = aws_vpc.demo-vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index + 1]

  tags = merge(
    {
      Name        = "demo-PrivateSN",
      Project     = var.project
    },
    var.tags
  )
}

resource "aws_route_table" "PrivateRT" {

  vpc_id = aws_vpc.demo-vpc.id

  tags = merge(
    {
      Name        = "demo-PrivateRT",
      Project     = var.project
    },
    var.tags
  )
}

resource "aws_route" "Private" {
  count = length(var.private_subnet_cidr_blocks)

  route_table_id         = aws_route_table.PrivateRT.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.demo-NATGW[count.index].id

  timeouts {
      create = "10m"
      update = "6m"
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr_blocks)

  subnet_id      = aws_subnet.privateSN[count.index].id
  route_table_id = aws_route_table.PrivateRT.id
}
