output "api_url" {
  description = "URL de la API via ALB"
  value       = "http://${module.compute.alb_dns_name}"
}

output "alb_dns_name" {
  value = module.compute.alb_dns_name
}

output "ecs_cluster_name" {
  value = module.compute.ecs_cluster_name
}

output "db_endpoint" {
  description = "Endpoint RDS PostgreSQL (interno)"
  value       = module.data.db_endpoint
}

output "redis_endpoint" {
  description = "Endpoint ElastiCache Redis (interno)"
  value       = module.data.redis_endpoint
}

output "db_secret_arn" {
  description = "ARN del secret en Secrets Manager"
  value       = module.data.db_secret_arn
}

output "ecr_repository_url" {
  description = "URL del repositorio ECR"
  value       = module.ecr.repository_url
}

output "sns_topic_arn" {
  description = "ARN del SNS topic de alertas"
  value       = module.observability.sns_topic_arn
}

output "dashboard_url" {
  description = "URL del CloudWatch Dashboard"
  value       = module.observability.dashboard_url
}
