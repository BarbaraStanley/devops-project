# Route 53 to load balancer
resource "aws_route53_zone" "main" {
  name = "devbarbea.me"
  tags = {
    Environment = "devops"
  }
}

/* data "kubernetes_service" "ingress" {
  metadata {
    name = "aws-load-balancer-controller"
    namespace = "kube-system"
  }
  depends_on = [helm_release.aws_lb_controller]
}
 
resource "aws_route53_record" "socks" {
  zone_id = aws_route53_zone.main.zone_id
  name = "sock-shop.devbarbea.me"
  type = "CNAME"
  ttl = "300"
  records = [data.kubernetes_service.ingress.status[0].load_balancer[0].ingress[0].hostname]
}
resource "aws_route53_record" "idapp" {
  zone_id = aws_route53_zone.main.zone_id
  name = "id-app.devbarbea.me"
  type = "CNAME"
  ttl = "300"
  records = [data.kubernetes_service.ingress.status[0].load_balancer[0].ingress[0].hostname]
} */