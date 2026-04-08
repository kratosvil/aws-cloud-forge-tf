# ============================================================
# PHASE 1 — NETWORKING
# ============================================================

module "networking" {
  source = "./modules/networking"

  project_name          = var.project_name
  vpc_cidr              = var.vpc_cidr
  subnet_public_a_cidr  = var.subnet_public_a_cidr
  subnet_public_b_cidr  = var.subnet_public_b_cidr
  subnet_private_a_cidr = var.subnet_private_a_cidr
  subnet_private_b_cidr = var.subnet_private_b_cidr
  subnet_data_a_cidr    = var.subnet_data_a_cidr
  subnet_data_b_cidr    = var.subnet_data_b_cidr
}

# ============================================================
# PHASE 2 — COMPUTE
# ============================================================

module "compute" {
  source = "./modules/compute"

  project_name        = var.project_name
  aws_region          = var.aws_region
  vpc_id              = module.networking.vpc_id
  subnet_public_a_id  = module.networking.subnet_public_a_id
  subnet_public_b_id  = module.networking.subnet_public_b_id
  subnet_private_a_id = module.networking.subnet_private_a_id
  subnet_private_b_id = module.networking.subnet_private_b_id
  sg_alb_id           = module.networking.sg_alb_id
  sg_ecs_id           = module.networking.sg_ecs_id
  container_image     = var.container_image
  desired_count       = var.desired_count
  db_secret_arn       = module.data.db_secret_arn
  db_host             = module.data.db_host
  redis_host          = module.data.redis_endpoint
  redis_port          = "6379"
}

# ============================================================
# PHASE 5.5 — ECR
# ============================================================

module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
}

# ============================================================
# PHASE 3 — DATA
# ============================================================

module "data" {
  source = "./modules/data"

  project_name        = var.project_name
  vpc_id              = module.networking.vpc_id
  subnet_data_a_id    = module.networking.subnet_data_a_id
  subnet_data_b_id    = module.networking.subnet_data_b_id
  subnet_private_a_id = module.networking.subnet_private_a_id
  subnet_private_b_id = module.networking.subnet_private_b_id
  sg_rds_id           = module.networking.sg_rds_id
  sg_redis_id         = module.networking.sg_redis_id
  db_username         = var.db_username
  db_password         = var.db_password
  db_name             = var.db_name
}

# ============================================================
# PHASE 4 — OBSERVABILITY
# ============================================================

module "observability" {
  source = "./modules/observability"

  project_name                = var.project_name
  aws_region                  = var.aws_region
  alert_email                 = var.alert_email
  ecs_cluster_name            = module.compute.ecs_cluster_name
  ecs_service_name            = module.compute.ecs_service_name
  db_instance_identifier      = module.data.db_instance_identifier
  alb_arn_suffix              = module.compute.alb_arn_suffix
  alb_target_group_arn_suffix = module.compute.alb_target_group_arn_suffix
}
