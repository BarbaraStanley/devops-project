data "aws_eks_cluster_auth" "cluster" {
  name = "devops-cluster"
}

provider "kubernetes" {
  host                   = aws_eks_cluster.devops-cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.devops-cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "eks-kubeconfig" {
  source     = "hyperbadger/eks-kubeconfig/aws"
  version    = "1.0.0"

  depends_on = [aws_eks_cluster.devops-cluster]
  cluster_id =  aws_eks_cluster.devops-cluster.cluster_id
  }

resource "local_file" "kubeconfig" {
  content  = module.eks-kubeconfig.kubeconfig
  filename = "kubeconfig_devops-cluster"
}

/* provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    }
}

resource "helm_release" "ingress" {
  name       = "ingress"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  version    = "1.4.6"

  set {
    name  = "autoDiscoverAwsRegion"
    value = "true"
  }
  set {
    name  = "autoDiscoverAwsVpcID"
    value = "true"
  }
  set {
    name  = "clusterName"
    value = "devops-cluster"
  }
} */