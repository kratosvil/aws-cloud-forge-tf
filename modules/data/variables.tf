variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_data_a_id" {
  type = string
}

variable "subnet_data_b_id" {
  type = string
}

variable "subnet_private_a_id" {
  type = string
}

variable "subnet_private_b_id" {
  type = string
}

variable "sg_rds_id" {
  type = string
}

variable "sg_redis_id" {
  type = string
}

variable "db_name" {
  description = "Nombre de la base de datos PostgreSQL"
  type        = string
  default     = "acfdb"
}

variable "db_username" {
  description = "Usuario master de RDS"
  type        = string
}

variable "db_password" {
  description = "Password master de RDS"
  type        = string
  sensitive   = true
}
