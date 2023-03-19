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


# Create Jenkins server
data "aws_ami" "main" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "Web_keys" {
  key_name   = "BarbKey"
  public_key = file("/mnt/c/Users/USER/Desktop/DevBarbea/altschool-cloud-journey/AWS/Terraform/BarbKey.pub")
}

resource "aws_instance" "bast-jenks" {
  vpc_security_group_ids = [aws_security_group.dev_sg.id]
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.main.id
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

# User data or ansible?
# export ip and provision with ansible
/* resource "local_file" "hosts" {
  filename = "hosts"
  content  = ${aws_instance.bast-jenks.public_ip}
} */

# Create eks cluster
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "devops" {
  name               = "eks-cluster"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "dev-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.devops.name
}

resource "aws_eks_cluster" "devops-cluster" {
  name     = "devops-cluster"
  role_arn = aws_iam_role.devops.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.dev_public_subnet1.id,
      aws_subnet.dev_public_subnet2.id,
      aws_subnet.dev_private_subnet1.id,
      aws_subnet.dev_private_subnet2.id,
    ]
  }

  # To ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.dev-AmazonEKSClusterPolicy
  ]
}





