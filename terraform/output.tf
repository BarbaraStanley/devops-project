output "endpoint" {
  value = aws_eks_cluster.devops-cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.devops-cluster.certificate_authority[0].data
}


