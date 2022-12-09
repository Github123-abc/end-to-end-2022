
#create a vpc
resource "aws_vpc" "H-vpc" {
  cidr_block           = var.cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "H-vpc"
  }
}
#publicsublic
resource "aws_subnet" "H-publicsubnet" {
  count                   = length(var.az)
  vpc_id                  = aws_vpc.H-vpc.id
  cidr_block              = element(var.H-publicsubnet, count.index)
  map_public_ip_on_launch = "true"
  availability_zone       = element(var.az, count.index)

  tags = {
    Name = "H-public1-${count.index + 1}"
  }
}
#H-privatesubnet
resource "aws_subnet" "H-privatesubnet" {
  count      = length(var.az)
  vpc_id     = aws_vpc.H-vpc.id
  cidr_block = element(var.H-privatesubnet, count.index)
  # map_public_ip_on_launch = "true"
  availability_zone = element(var.az, count.index)
  tags = {
    Name = "H-private1-${count.index + 1}"
  }
}
#H-datasubnet
resource "aws_subnet" "H-datasubnet" {
  count      = length(var.az)
  vpc_id     = aws_vpc.H-vpc.id
  cidr_block = element(var.H-datasubnet, count.index)
  # map_public_ip_on_launch = "true"
  availability_zone = element(var.az, count.index)
  tags = {
    Name = "H-data1-${count.index + 1}"
  }
}

#internet gateway
resource "aws_internet_gateway" "H-igw" {
  vpc_id = aws_vpc.H-vpc.id

  tags = {
    Name = "H-igw"
  }
}


#nat-gateway elastic ip
resource "aws_eip" "H-eip" {
  vpc = true

  tags = {
    "nmae" = "H-eip"
  }
}

resource "aws_nat_gateway" "H-nat-gw" {
  allocation_id = aws_eip.H-eip.id
  subnet_id     = aws_subnet.H-publicsubnet[0].id

  tags = {
    Name = "H-nat-gw"
  }
}


#publiroute
resource "aws_route_table" "H-publicroute" {
  vpc_id = aws_vpc.H-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.H-igw.id
  }
  tags = {
    Name = "H-publicroute"
  }

}
#H-privateroute
resource "aws_route_table" "H-privateroute" {
  vpc_id = aws_vpc.H-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.H-nat-gw.id
  }
  tags = {
    Name = "H-privateroute"
  }
}
#H-dataroute
resource "aws_route_table" "H-dataroute" {
  vpc_id = aws_vpc.H-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.H-nat-gw.id
  }
  tags = {
    Name = "H-dataroute"
  }
}

#public-association
resource "aws_route_table_association" "public-association" {
  count          = length(var.H-publicsubnet)
  subnet_id      = element(aws_subnet.H-publicsubnet.*.id, count.index)
  route_table_id = aws_route_table.H-publicroute.id
}
#private-association
resource "aws_route_table_association" "private-association" {
  count          = length(var.H-privatesubnet)
  subnet_id      = element(aws_subnet.H-privatesubnet.*.id, count.index)
  route_table_id = aws_route_table.H-privateroute.id
}
#data-association
resource "aws_route_table_association" "data-association" {
  count          = length(var.H-datasubnet)
  subnet_id      = element(aws_subnet.H-datasubnet.*.id, count.index)
  route_table_id = aws_route_table.H-dataroute.id
}