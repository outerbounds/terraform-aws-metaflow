
output "alb_dns_name" {
  value       = aws_lb.this.dns_name
  description = "UI ALB DNS name"
}

output "alb_arn" {
  value       = aws_lb.this.arn
  description = "UI ALB ARN"
}

output "ui_static_target_group_arn" {
  value       = aws_lb_target_group.ui_static.arn
  description = "UI Static target group ARN"
}

output "ui_backend_target_group_arn" {
  value       = aws_lb_target_group.ui_backend.arn
  description = "UI Backend target group ARN"
}
