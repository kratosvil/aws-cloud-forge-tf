variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_public_a_id" {
  type = string
}

variable "subnet_public_b_id" {
  type = string
}

variable "subnet_private_a_id" {
  type = string
}

variable "subnet_private_b_id" {
  type = string
}

variable "sg_alb_id" {
  type = string
}

variable "sg_ecs_id" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "container_image" {
  description = "Imagen Docker del contenedor FastAPI"
  type        = string
}

variable "container_port" {
  description = "Puerto que expone el contenedor"
  type        = number
  default     = 8000
}

variable "task_cpu" {
  description = "CPU units para el Fargate task (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memoria en MB para el Fargate task"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Número de tasks corriendo"
  type        = number
  default     = 1
}

variable "db_secret_arn" {
  description = "ARN del secret de credenciales DB en Secrets Manager"
  type        = string
  default     = ""
}
