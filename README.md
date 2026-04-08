# aws-cloud-forge-tf

Production-style three-tier AWS infrastructure built with Terraform. Simulates a real-world cloud environment with containerized API, managed database, caching layer, secrets management, and observability.

Built by **Samir Villa** as part of a hands-on DevOps/MLOps infrastructure practice series.

> Companion project: [aws-infra-forge](https://github.com/kratosvil/aws-terraform-blueprints) — foundational AWS/Terraform labs.
> Upcoming: `aws-cloud-forge-cf` — same architecture implemented with AWS CloudFormation.

---

## Architecture

```
                          Internet
                              |
                        [ Route 53 ]
                     (conceptual - Phase 7)
                              |
                 ┌────────────────────────┐
                 │  Application Load      │
                 │  Balancer (ALB)        │
                 │  subnet-public-a/b     │
                 └───────────┬────────────┘
                             │
                 ┌───────────┴────────────┐
                 │   ECS Fargate          │
                 │   FastAPI CRUD API     │
                 │   subnet-private-a/b   │
                 └───────────┬────────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
  ┌───────────┴──────────┐    ┌─────────────┴──────────┐
  │  RDS PostgreSQL       │    │  ElastiCache Redis      │
  │  Multi-AZ             │    │  cache.t3.micro         │
  │  subnet-data-a/b      │    │  subnet-private-a/b     │
  └───────────────────────┘    └────────────────────────┘
              │
  ┌───────────┴──────────────────────────────┐
  │           Supporting Services            │
  │                                          │
  │  NAT Gateway     → internet egress       │
  │  Secrets Manager → DB + Redis creds      │
  │  CloudWatch      → logs per service      │
  │  SNS             → critical alerts       │
  │  IAM Roles       → per-service perms     │
  └──────────────────────────────────────────┘
```

---

## Network Layout

```
VPC — 10.0.0.0/16
│
├── subnet-public-a   10.0.1.0/24  us-east-1a  → ALB, NAT Gateway
├── subnet-public-b   10.0.2.0/24  us-east-1b  → ALB (Multi-AZ)
│
├── subnet-private-a  10.0.3.0/24  us-east-1a  → ECS Fargate, ElastiCache
├── subnet-private-b  10.0.4.0/24  us-east-1b  → ECS Fargate, ElastiCache
│
├── subnet-data-a     10.0.5.0/24  us-east-1a  → RDS primary
└── subnet-data-b     10.0.6.0/24  us-east-1b  → RDS standby (Multi-AZ failover)
```

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check — verifies DB and Redis connectivity |
| GET | `/items` | List all items (Redis cache → PostgreSQL fallback) |
| GET | `/items/{id}` | Get item by ID |
| POST | `/items` | Create new item |
| DELETE | `/items/{id}` | Delete item by ID |
| GET | `/docs` | Interactive API documentation (Swagger UI) |

---

## Stack

- **IaC:** Terraform >= 1.0 / AWS Provider ~> 5.0
- **Compute:** ECS Fargate
- **API:** FastAPI + Python 3.11
- **Database:** RDS PostgreSQL 15 Multi-AZ (db.t3.micro)
- **Cache:** ElastiCache Redis 7 (cache.t3.micro)
- **Load Balancer:** ALB with health checks
- **Secrets:** AWS Secrets Manager
- **Observability:** CloudWatch Logs + SNS Alerts
- **Networking:** VPC, 6 subnets, NAT Gateway, IGW, Security Groups
- **Security:** IAM Roles per service, least privilege

---

## Secrets Flow

Credentials never touch the codebase or repository.

```
terraform.tfvars (local, gitignored)
    └── Secrets Manager (AWS, encrypted at rest)
         └── ECS Task Definition (ARN injected as env var)
              └── FastAPI (calls boto3 at runtime → gets credentials)
                   └── psycopg2 → RDS PostgreSQL
```

DB host is passed as a non-sensitive env var. Only credentials (username, password, dbname) live in Secrets Manager.

---

## Module Structure

```
aws-cloud-forge-tf/
├── main.tf                   → root module, calls all child modules
├── variables.tf
├── outputs.tf
├── provider.tf
├── terraform.tfvars          → gitignored
├── app/
│   ├── main.py               → FastAPI application
│   ├── requirements.txt
│   └── Dockerfile
└── modules/
    ├── networking/            → VPC, subnets, NAT GW, route tables, SGs
    ├── compute/               → ECS cluster, Fargate task, ALB, IAM
    ├── data/                  → RDS, ElastiCache, Secrets Manager
    ├── ecr/                   → ECR repository + lifecycle policy
    └── observability/         → CloudWatch dashboard, SNS, alarms
```

---

## Phases

| Phase | Content | Status |
|-------|---------|--------|
| 0 | Design, repo, structure, README | Complete |
| 1 | Networking — VPC, subnets, NAT GW, SGs | Complete |
| 2 | Compute — ECS, Fargate, ALB, IAM | Complete |
| 3 | Data — RDS, ElastiCache, Secrets Manager | Complete |
| 4 | Observability — CloudWatch, SNS alarms | Complete |
| 5 | Security review — least privilege IAM | Complete |
| 5.5 | FastAPI — ECR, Docker image, full CRUD deploy | Complete |
| 6 | Validation, end-to-end test, destroy | Complete |
| 7 | Route 53 — conceptual walkthrough | Complete |

---

## Cost Awareness

All resources are sized for minimal cost (db.t3.micro, cache.t3.micro, 0.25 vCPU Fargate). NAT Gateway is the most expensive component — infrastructure should always be destroyed after validation to avoid ongoing charges.

---

## Author

**Samir Villa** — DevOps / MLOps Infrastructure Engineer
[github.com/kratosvil](https://github.com/kratosvil)
