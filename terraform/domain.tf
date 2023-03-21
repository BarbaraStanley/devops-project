# Route 53 to load balancer
resource "aws_route53_zone" "main" {
  name = "devbarbea.me"
  tags = {
    Environment = "devops"
  }
}
