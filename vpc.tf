# Resource Block
# Resource-1: Create VPC
resource "aws_vpc" "vpc-dev" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "name" = "vpc-dev"
  }
}

# Resource-2: Create Subnets
resource "aws_subnet" "public" {
  count = "${length(var.subnet_cidrs_public)}"
  vpc_id = aws_vpc.vpc-dev.id
  cidr_block = "${var.subnet_cidrs_public[count.index]}"
  availability_zone = "${var.avail_zones[count.index]}"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count = "${length(var.subnet_cidrs_private)}"
  vpc_id = aws_vpc.vpc-dev.id
  cidr_block = "${var.subnet_cidrs_private[count.index]}"
  availability_zone = "${var.avail_zones[count.index]}"
}

# Resource-3: Internet Gateway
resource "aws_internet_gateway" "vpc-dev-igw" {
  vpc_id = aws_vpc.vpc-dev.id
}

resource "aws_nat_gateway" "vpc-dev-ngw" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "gw NAT"
  }
}

# Resource-4: Create Route Table

resource "aws_route_table" "vpc-dev-public-route-table" {
  vpc_id = aws_vpc.vpc-dev.id
}
resource "aws_route_table" "vpc-dev-private-route-table" {
  vpc_id = aws_vpc.vpc-dev.id
}

# Resource-5: Create Route in Route Table for Internet Access
resource "aws_route" "vpc-dev-public-route" {
  route_table_id = aws_route_table.vpc-dev-public-route-table.id 
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.vpc-dev-igw.id 
}
resource "aws_route" "vpc-dev-private-route" {
  route_table_id = aws_route_table.vpc-dev-private-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.vpc-dev-ngw.id
}

# Resource-6: Associate the Route Table with the Subnet
resource "aws_route_table_association" "vpc-dev-public-route-table-associate" {
  count = "${length(var.subnet_cidrs_public)}"
  route_table_id = aws_route_table.vpc-dev-public-route-table.id 
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
}
resource "aws_route_table_association" "vpc-dev-private-route-table-associate" {
  count = "${length(var.subnet_cidrs_private)}"
  route_table_id = aws_route_table.vpc-dev-private-route-table.id
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
}

# Resource-7: Create Security Group
resource "aws_security_group" "dev-vpc-sg" {
  name = "dev-vpc-default-sg"
  vpc_id = aws_vpc.vpc-dev.id
  description = "Dev VPC Default Security Group"

  ingress {
    description = "Allow Port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all ip and ports outboun"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

#CREATE ELASTIC IP RESOURCE
# Resource-9: Create Elastic IP
resource "aws_eip" "nat_gateway"{
  vpc = true
  depends_on = [ aws_internet_gateway.vpc-dev-igw ]
}

