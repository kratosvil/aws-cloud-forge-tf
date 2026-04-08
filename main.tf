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
