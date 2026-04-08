output "alb_dns_name" {
  description = "DNS del ALB — URL de acceso a la API"
  value       = aws_lb.main.dns_name
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  value = aws_ecs_service.api.name
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.api.arn
}

output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix del ALB — usado para métricas CloudWatch"
  value       = aws_lb.main.arn_suffix
}

output "alb_target_group_arn_suffix" {
  description = "ARN suffix del Target Group — usado para métricas CloudWatch"
  value       = aws_lb_target_group.api.arn_suffix
}
