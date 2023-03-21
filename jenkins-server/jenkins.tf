terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["/mnt/c/Users/USER/.aws/credentials"] #default, added for documentation puposes
  profile                  = "vscode"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "jenkins-automation"
  }
}

resource "aws_subnet" "dev_public_subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.1.0.0/16"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    "Name"                                 = "jenkins"
  }
}

resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "jenkins-igw"
  }
}
# Create route table
resource "aws_route_table" "dev_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "jenkins-rt"
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

#Security group
resource "aws_security_group" "dev_sg" {
  name        = "devops-Sg"
  vpc_id      = aws_vpc.main.id
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

# Create Jenkins server
/* data "aws_ami" "main" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.0.20230315.0-kernel-6.1-x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
} */

resource "aws_key_pair" "Web_keys" {
  key_name   = "BarbKey"
  public_key = file("/mnt/c/Users/USER/Desktop/DevBarbea/altschool-cloud-journey/AWS/Terraform/BarbKey.pub")
}

resource "aws_instance" "bast-jenks" {
  vpc_security_group_ids = [aws_security_group.dev_sg.id]
  instance_type          = "t2.micro"
  ami                    = "ami-005f9685cb30f234b"
  key_name               = aws_key_pair.Web_keys.key_name
  subnet_id              = aws_subnet.dev_public_subnet1.id
  user_data              = file("setup.sh")
  root_block_device {
    volume_size = 8
  }
  tags = {
    "Name" = "Bastion-jenkins-Server"
  }
}

output "bastion_ip" {
  value = aws_instance.bast-jenks.public_ip
}
