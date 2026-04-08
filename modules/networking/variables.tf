variable "vpc_cidr" {
  description = "CIDR block de la VPC"
  type        = string
}

variable "subnet_public_a_cidr" {
  description = "CIDR subnet pública us-east-1a (ALB, NAT GW)"
  type        = string
}

variable "subnet_public_b_cidr" {
  description = "CIDR subnet pública us-east-1b (ALB Multi-AZ)"
  type        = string
}

variable "subnet_private_a_cidr" {
  description = "CIDR subnet privada us-east-1a (ECS, ElastiCache)"
  type        = string
}

variable "subnet_private_b_cidr" {
  description = "CIDR subnet privada us-east-1b (ECS, ElastiCache)"
  type        = string
}

variable "subnet_data_a_cidr" {
  description = "CIDR subnet datos us-east-1a (RDS primary)"
  type        = string
}

variable "subnet_data_b_cidr" {
  description = "CIDR subnet datos us-east-1b (RDS standby)"
  type        = string
}

variable "project_name" {
  description = "Nombre del proyecto — usado como prefijo en recursos"
  type        = string
}
