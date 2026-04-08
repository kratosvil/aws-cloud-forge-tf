output "repository_url" {
  description = "URL del repositorio ECR"
  value       = aws_ecr_repository.api.repository_url
}

output "registry_id" {
  description = "ID del registro ECR (account ID)"
  value       = aws_ecr_repository.api.registry_id
}
