output "lb_arn" {
  description = "The ARN of the load balancer."
  value       = aws_alb.alb.arn
}