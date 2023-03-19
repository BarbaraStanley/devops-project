#configure VPC and subnets
resource "aws_vpc" "dev_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Devops"
  }
}

resource "aws_subnet" "dev_public_subnet1" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    "Name"                                 = "dev-public1"
    "kubernetes.io/role/elb"               = "1"
    "kubernetes.io/cluster/devops-cluster" = "shared"
  }
}
resource "aws_subnet" "dev_public_subnet2" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    "Name"                                 = "dev-public2"
    "kubernetes.io/role/elb"               = "1"
    "kubernetes.io/cluster/devops-cluster" = "shared"
  }
}
resource "aws_subnet" "dev_private_subnet1" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1a"

  tags = {
    "Name"                                 = "dev-private1"
    "kubernetes.io/role/internal-elb"      = "1"
    "kubernetes.io/cluster/devops-cluster" = "shared"
  }
}
resource "aws_subnet" "dev_private_subnet2" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1b"

  tags = {
    "Name"                                 = "dev-private2"
    "kubernetes.io/role/internal-elb"      = "1"
    "kubernetes.io/cluster/devops-cluster" = "shared"
  }
}

# setup internet and nat gateway for public and private subnets
resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    "Name" = "dev-igw"
  }
}
# Create route table
resource "aws_route_table" "dev_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    "Name" = "dev-rt"
  }
}
# Create route
resource "aws_route" "dev_default_r" {
  route_table_id         = aws_route_table.dev_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev_igw.id

}

#Associate public subnets to route table
resource "aws_route_table_association" "dev_pubSubnet_r1" {
  subnet_id      = aws_subnet.dev_public_subnet1.id
  route_table_id = aws_route_table.dev_rt.id

}
resource "aws_route_table_association" "dev_pubSubnet_r2" {
  subnet_id      = aws_subnet.dev_public_subnet2.id
  route_table_id = aws_route_table.dev_rt.id

}

# Allocate elastic IP
resource "aws_eip" "dev_nat_eip" {
  vpc = true
}
# Create NAT gateway  
resource "aws_nat_gateway" "dev_ngw" {
  subnet_id     = aws_subnet.dev_public_subnet1.id
  allocation_id = aws_eip.dev_nat_eip.id

  tags = {
    "Name" = "alt-natgw-1a"
  }
  depends_on = [aws_internet_gateway.dev_igw]
}

# Create route table
resource "aws_route_table" "dev_ngw_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    "Name" = "dev-route-nat"
  }
}

# Create route
resource "aws_route" "dev_ngw_r" {
  route_table_id         = aws_route_table.dev_ngw_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.dev_ngw.id

}

# Associate private subnets to natgw route table
resource "aws_route_table_association" "dev_priv_r1" {
  subnet_id      = aws_subnet.dev_private_subnet1.id
  route_table_id = aws_route_table.dev_ngw_rt.id
}
resource "aws_route_table_association" "dev_priv_r2" {
  subnet_id      = aws_subnet.dev_private_subnet2.id
  route_table_id = aws_route_table.dev_ngw_rt.id
}

#Security group
resource "aws_security_group" "dev_sg" {
  name        = "devops-Sg"
  vpc_id      = aws_vpc.dev_vpc.id
  description = "Configure http, https and ssh for bastion/jenkins"

  ingress {
    description = "Allow ssh"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    description = "Allow http"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    description = "Allow jenkins"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}