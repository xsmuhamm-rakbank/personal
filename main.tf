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
  username                   = jsondecode(data.aws_secretsmanager_secret_version.admin_user_pass.secret_string)["username"]
  password                   = jsondecode(data.aws_secretsmanager_secret_version.admin_user_pass.secret_string)["password"]
}

create secret with random password 

  "deh-db-dev-01-secret" = {
    name        = "deh-db-dev-01-secret"
    description = "Secret used by dev rds database"
    tags = {
      Environment  = "deh-dev",
      map-migrated = "d-server-03is5ms7k94v6w",
    }
  }

resource "random_password" "password" {
  length           = 16
  special          = false
  override_special = true
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
}
resource "aws_secretsmanager_secret_version" "admin_user_pass" {
  secret_id = var.secret_id
  secret_string = jsonencode({
    username = "postgres"
    password = random_password.password.result
  })
  version_stages = ["AWSCURRENT"]
}
data "aws_secretsmanager_secret_version" "admin_user_pass" {
  secret_id = var.secret_id

  depends_on = [aws_secretsmanager_secret_version.admin_user_pass]
}
