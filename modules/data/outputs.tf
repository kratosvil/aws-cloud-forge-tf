output "db_endpoint" {
  description = "Endpoint de conexión RDS PostgreSQL"
  value       = aws_db_instance.main.endpoint
}

output "db_name" {
  value = aws_db_instance.main.db_name
}

output "redis_endpoint" {
  description = "Endpoint de conexión ElastiCache Redis"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "redis_port" {
  value = aws_elasticache_cluster.redis.port
}

output "db_secret_arn" {
  description = "ARN del secret en Secrets Manager"
  value       = aws_secretsmanager_secret.db.arn
}

output "db_instance_identifier" {
  description = "Identificador de la instancia RDS — usado para métricas CloudWatch"
  value       = aws_db_instance.main.identifier
}

output "db_host" {
  description = "Host de RDS sin puerto — para env var DB_HOST"
  value       = aws_db_instance.main.address
}
