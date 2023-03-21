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
  shared_credentials_files = ["/mnt/c/Users/USER/.aws/credentials"] 
  profile                  = "vscode"
}

resource "aws_key_pair" "Web_keys" {
  key_name   = "BarbKey"
  public_key = file("/mnt/c/Users/USER/Desktop/DevBarbea/altschool-cloud-journey/AWS/Terraform/BarbKey.pub")
}


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





