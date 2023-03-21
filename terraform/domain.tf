# Route 53 to load balancer
resource "aws_route53_zone" "main" {
  name = "devbarbea.me"
  tags = {
    Environment = "devops"
  }
}

data "kubernetes_service" "ingress" {
  metadata {
    name = "ingress-nginx-ingress-nginx"
    namespace = "ingress-nginx"
  }
  depends_on = [helm_release.nginx_ingress]
}
 
resource "aws_route53_record" "ingress" {
  zone_id = aws_route53_zone.main.zone_id
  name = "devbarbea.me"
  type = "CNAME"
  ttl = "300"
  records = [data.kubernetes_service.ingress.status[0].load_balancer[0].ingress[0].hostname]
}