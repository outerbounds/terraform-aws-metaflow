
output "alb_dns_name" {
  value       = aws_lb.this.dns_name
  description = "UI ALB DNS name"
}
