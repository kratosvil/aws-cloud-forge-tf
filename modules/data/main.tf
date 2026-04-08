# ============================================================
# SECRETS MANAGER — credenciales DB
# ============================================================

resource "aws_secretsmanager_secret" "db" {
  name                    = "${var.project_name}/db-credentials"
  recovery_window_in_days = 0

  tags = { Name = "${var.project_name}-db-secret" }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    dbname   = var.db_name
  })
}

# ============================================================
# RDS — Subnet Group (requiere mínimo 2 AZs)
# ============================================================

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [var.subnet_data_a_id, var.subnet_data_b_id]

  tags = { Name = "${var.project_name}-db-subnet-group" }
}

# ============================================================
# RDS — PostgreSQL Multi-AZ
# ============================================================

resource "aws_db_instance" "main" {
  identifier        = "${var.project_name}-postgres"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.sg_rds_id]

  multi_az               = true
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false

  tags = { Name = "${var.project_name}-postgres" }
}

# ============================================================
# ELASTICACHE — Subnet Group
# ============================================================

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-redis-subnet-group"
  subnet_ids = [var.subnet_private_a_id, var.subnet_private_b_id]

  tags = { Name = "${var.project_name}-redis-subnet-group" }
}

# ============================================================
# ELASTICACHE — Redis
# ============================================================

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.project_name}-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [var.sg_redis_id]

  tags = { Name = "${var.project_name}-redis" }
}
