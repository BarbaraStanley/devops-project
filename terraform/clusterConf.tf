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
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.devops-cluster.id]
      command     = "aws"
    }
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
/* resource "helm_release" "nginx_ingress" {
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
  */
#Create Service Account for ALB
/* resource "kubernetes_service_account" "aws-load-balancer-controller" {
  metadata {
    name = "aws-load-balancer-controller"
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = "${aws_iam_role.lb.arn}"
    }
  }
  secret {
    name = "${kubernetes_secret.aws-load-balancer-controller.metadata.0.name}"
  }
  depends_on = [kubernetes_secret.aws-load-balancer-controller,
                aws_iam_role.lb]
}

resource "kubernetes_secret" "aws-load-balancer-controller" {
  metadata {
    name = "aws-load-balancer-controller"
  }
} */
 
#Install AWS LB controller
resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.4.1"
 
  set {
    name  = "clusterName"
    value = aws_eks_cluster.devops-cluster.id
  }
 
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
 
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.lb.arn
  }

  depends_on = [
    aws_eks_node_group.example,
    aws_iam_role_policy_attachment.lb
  ]
}