resource "aws_iam_policy" "lb" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  policy = jsonencode(jsondecode(file("eks-lb-policy.json")))
}
 
resource "aws_iam_role" "lb" {
  name               = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}
 
resource "aws_iam_role_policy_attachment" "lb" {
  role       = aws_iam_role.lb.name
  policy_arn = aws_iam_policy.lb.arn
}