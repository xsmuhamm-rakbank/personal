# Random password generation
resource "random_password" "password" {
  length           = 16
  special          = false
  override_special = true
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
}

# Secrets Manager secret definition
resource "aws_secretsmanager_secret" "digital_wallet_secret" {
  name        = "digital-wallet-secret"
  description = "Secret used by digital wallet RDS database"
  tags = {
    Environment  = "deh-dev"
    map-migrated = "d-server-03is5ms7k94v6w"
  }
}

# Secrets Manager secret version to store username and password
resource "aws_secretsmanager_secret_version" "admin_user_pass" {
  secret_id = aws_secretsmanager_secret.digital_wallet_secret.id
  secret_string = jsonencode({
    username = var.rds_username  # Define username dynamically through variables
    password = random_password.password.result
  })
}

# Data source to fetch the secret version
data "aws_secretsmanager_secret_version" "admin_user_pass" {
  secret_id = aws_secretsmanager_secret.digital_wallet_secret.id

  depends_on = [aws_secretsmanager_secret_version.admin_user_pass]
}

# RDS Module with dependencies
module "digital-wallet" {
  source = "git::https://github.com/rakbank-internal/terraform-aws-rds-postgres-module.git?ref=v1.3.0"

  vpc_id                     = var.vpc_id
  db_name                    = var.dw_db_name
  ingress_cidr_blocks        = var.db_ingress_cidr_blocks
  engine_version             = var.engine_version
  instance_class             = var.dw_instance_class
  family                     = var.family
  major_engine_version       = var.major_engine_version
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  port                       = var.port
  db_subnet_group_name       = var.db_subnet_group_name
  subnets                    = var.subnets
  apply_immediately          = var.apply_immediately
  tags                       = var.tags
  deletion_protection        = var.deletion_protection
  multi_az                   = var.multi_az
  allocated_storage          = var.allocated_storage
  max_allocated_storage      = var.max_allocated_storage
  storage_type               = var.storage_type
  iops                       = var.iops
  create_replica             = var.create_replica
  replica_count              = var.replica_count
  force_ssl                  = var.force_ssl

  # Username and password retrieved from Secrets Manager
  username = jsondecode(data.aws_secretsmanager_secret_version.admin_user_pass.secret_string)["username"]
  password = jsondecode(data.aws_secretsmanager_secret_version.admin_user_pass.secret_string)["password"]

  # Explicit dependency to ensure the secret is created before RDS
  depends_on = [
    aws_secretsmanager_secret.digital_wallet_secret,
    aws_secretsmanager_secret_version.admin_user_pass
  ]
}

# Variables for RDS username
variable "rds_username" {
  description = "RDS username to be stored in Secrets Manager"
  type        = string
  default     = "postgres"  # You can override this as needed
}
