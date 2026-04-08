# ============================================================
# VPC
# ============================================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "${var.project_name}-vpc" }
}

# ============================================================
# SUBNETS — Públicas (ALB, NAT Gateway)
# ============================================================

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_public_a_cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = { Name = "${var.project_name}-subnet-public-a" }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_public_b_cidr
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = { Name = "${var.project_name}-subnet-public-b" }
}

# ============================================================
# SUBNETS — Privadas (ECS Fargate, ElastiCache)
# ============================================================

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private_a_cidr
  availability_zone = "us-east-1a"

  tags = { Name = "${var.project_name}-subnet-private-a" }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private_b_cidr
  availability_zone = "us-east-1b"

  tags = { Name = "${var.project_name}-subnet-private-b" }
}

# ============================================================
# SUBNETS — Datos (RDS — sin salida a internet)
# ============================================================

resource "aws_subnet" "data_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_data_a_cidr
  availability_zone = "us-east-1a"

  tags = { Name = "${var.project_name}-subnet-data-a" }
}

resource "aws_subnet" "data_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_data_b_cidr
  availability_zone = "us-east-1b"

  tags = { Name = "${var.project_name}-subnet-data-b" }
}

# ============================================================
# INTERNET GATEWAY
# ============================================================

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "${var.project_name}-igw" }
}

# ============================================================
# NAT GATEWAY (en subnet pública-a, sirve a subnets privadas)
# ============================================================

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = { Name = "${var.project_name}-nat-eip" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id

  tags = { Name = "${var.project_name}-nat-gw" }

  depends_on = [aws_internet_gateway.igw]
}

# ============================================================
# ROUTE TABLES
# ============================================================

# Pública — sale directo al IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "${var.project_name}-rt-public" }
}

# Privada — sale a internet via NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = { Name = "${var.project_name}-rt-private" }
}

# Datos — sin ruta a internet
resource "aws_route_table" "data" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "${var.project_name}-rt-data" }
}

# ============================================================
# ROUTE TABLE ASSOCIATIONS
# ============================================================

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "data_a" {
  subnet_id      = aws_subnet.data_a.id
  route_table_id = aws_route_table.data.id
}

resource "aws_route_table_association" "data_b" {
  subnet_id      = aws_subnet.data_b.id
  route_table_id = aws_route_table.data.id
}

# ============================================================
# SECURITY GROUPS
# ============================================================

# ALB — recibe tráfico HTTP desde internet
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-sg-alb"
  description = "Allow HTTP inbound from internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-sg-alb" }
}

# ECS — recibe tráfico solo desde el ALB
resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-sg-ecs"
  description = "Allow traffic from ALB only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "From ALB"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-sg-ecs" }
}

# RDS — recibe tráfico solo desde ECS
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-sg-rds"
  description = "Allow PostgreSQL from ECS only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  tags = { Name = "${var.project_name}-sg-rds" }
}

# ElastiCache — recibe tráfico solo desde ECS
resource "aws_security_group" "redis" {
  name        = "${var.project_name}-sg-redis"
  description = "Allow Redis from ECS only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Redis from ECS"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  tags = { Name = "${var.project_name}-sg-redis" }
}
