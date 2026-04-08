variable "project_name" {
  description = "Prefijo para nombrar recursos"
  type        = string
}

variable "aws_region" {
  description = "Región AWS"
  type        = string
}

variable "alert_email" {
  description = "Email para recibir alertas SNS"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Nombre del cluster ECS"
  type        = string
}

variable "ecs_service_name" {
  description = "Nombre del servicio ECS"
  type        = string
}

variable "db_instance_identifier" {
  description = "Identificador de la instancia RDS"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ARN suffix del ALB para métricas CloudWatch"
  type        = string
}

variable "alb_target_group_arn_suffix" {
  description = "ARN suffix del Target Group para métricas CloudWatch"
  type        = string
}
