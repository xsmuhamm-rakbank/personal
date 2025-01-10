module "secrets" {
  source = "git::https://github.com/rakbank-internal/terraform-aws-secrets-manager-module.git?ref=v1.0.0"

  for_each    = var.secrets
  name        = lookup(each.value, "name")
  description = lookup(each.value, "description", "")
  tags        = lookup(each.value, "tags")
}

  "digital_wallet_secret" = {
    name        = "digital-wallet-secret"
    description = "Secret used by digital wallet dev rds database"
    tags = {
      Environment  = "deh-dev",
      map-migrated = "d-server-03is5ms7k94v6w",
    }
  }

alidation failed: .
╷
│ Error: Reference to undeclared resource
│ 
│   on main.tf line 159, in resource "aws_secretsmanager_secret_version" "digital_wallet_pass":
│  159:     aws_secretsmanager_secret.digital_wallet_pass, # Ensure the secret is created first
│ 
│ A managed resource "aws_secretsmanager_secret" "digital_wallet_pass" has
│ not been declared in the root module.

################################################################################
# Digital Wallet (Bitpanda) - RDS Resources
################################################################################

resource "random_password" "password" {
  length           = 16
  special          = false
  override_special = true
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
}

# Inject the generated password into the created secret (second apply)
resource "aws_secretsmanager_secret_version" "digital_wallet_pass" {
  secret_id = var.dw_secret_id
  secret_string = jsonencode({
    username = var.dw_rds_username
    password = random_password.password.result # Use the password generated above
  })

  # Ensure that the random password is injected only after the secret is created
  depends_on = [
    aws_secretsmanager_secret.digital_wallet_pass, # Ensure the secret is created first
    random_password.password                       # Ensure password is generated before injecting into the secret
  ]
}

# Fetch the secret from AWS Secrets Manager (this step will depend on the secret version)
data "aws_secretsmanager_secret_version" "digital_wallet_pass" {
  secret_id = var.dw_secret_id # Use the secret ID from the variable

  # This ensures the secret version is fetched after it is created
  depends_on = [
    aws_secretsmanager_secret_version.digital_wallet_pass # Ensure the secret version is available
  ]
}

################################################################################
# Digital Wallet (Bitpanda) - RDS Module
################################################################################

module "digital_wallet" {
  source = "git::https://github.com/rakbank-internal/terraform-aws-rds-postgres-module.git?ref=v1.3.0"

  vpc_id                     = var.vpc_id
  db_name                    = var.dw_db_name
  ingress_cidr_blocks        = var.dw_db_ingress_cidr_blocks
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

  username = jsondecode(data.aws_secretsmanager_secret_version.digital_wallet_pass.secret_string)["username"]
  password = jsondecode(data.aws_secretsmanager_secret_version.digital_wallet_pass.secret_string)["password"]

  # Ensure the RDS module runs after the secret is created and the password is injected
  depends_on = [
    aws_secretsmanager_secret_version.digital_wallet_pass
  ]
}
