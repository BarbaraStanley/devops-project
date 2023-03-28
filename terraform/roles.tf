data "tls_certificate" "eks" {
  url = aws_eks_cluster.devops-cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.devops-cluster.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}
resource "aws_iam_policy" "lb" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  policy = jsonencode(jsondecode(file("eks-lb-policy.json")))
}
 
resource "aws_iam_role" "lb" {
  name               = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_role_policy.json
}
 
resource "aws_iam_role_policy_attachment" "lb" {
  role       = aws_iam_role.lb.name
  policy_arn = aws_iam_policy.lb.arn
}
