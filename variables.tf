variable "aws_region" {
  description = "Región AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefijo para nombrar recursos"
  type        = string
  default     = "acf"
}

# ── Networking ────────────────────────────────────────────
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_public_a_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "subnet_public_b_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "subnet_private_a_cidr" {
  type    = string
  default = "10.0.3.0/24"
}

variable "subnet_private_b_cidr" {
  type    = string
  default = "10.0.4.0/24"
}

variable "subnet_data_a_cidr" {
  type    = string
  default = "10.0.5.0/24"
}

variable "subnet_data_b_cidr" {
  type    = string
  default = "10.0.6.0/24"
}

# ── Compute ───────────────────────────────────────────────
variable "container_image" {
  description = "Imagen Docker del contenedor FastAPI (ECR o DockerHub)"
  type        = string
}

variable "desired_count" {
  description = "Número de tasks ECS corriendo"
  type        = number
  default     = 1
}

# ── Data ──────────────────────────────────────────────────
variable "db_name" {
  type    = string
  default = "acfdb"
}

variable "db_username" {
  description = "Usuario master de RDS"
  type        = string
}

variable "db_password" {
  description = "Password master de RDS — solo en terraform.tfvars, nunca en código"
  type        = string
  sensitive   = true
}
