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
