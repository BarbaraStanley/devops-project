data "aws_eks_cluster_auth" "cluster" {
  name = "devops-cluster"
}

provider "kubernetes" {
  host                   = aws_eks_cluster.devops-cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.devops-cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.devops-cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.devops-cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    }
}
/*
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

#Install Nginx Ingress Helm Chart
resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  namespace  = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "3.36.0"
  create_namespace = true
  values = [
    "${file("values.yaml")}"
  ]
 
  depends_on = [helm_release.aws_lb_controller]
}
 
data "aws_iam_role" "lb" {
  name = "AmazonEKSLoadBalancerControllerRole"
}
 
#Create Service Account for ALB
resource "kubernetes_service_account" "aws-load-balancer-controller" {
  metadata {
    name = "aws-load-balancer-controller"
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = "${data.aws_iam_role.lb.arn}"
    }
  }
}
 
#Install AWS LB controller
resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
 
  set {
    name  = "clusterName"
    value = "mon-dev"
  }
 
  set {
    name  = "serviceAccount.create"
    value = false
  }
 
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
}