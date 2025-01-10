################################################################################
# Random Password Generation
################################################################################

resource "random_password" "password" {
  length           = 16
  special          = false
  override_special = true
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
}

################################################################################
# Secret Version with Injected Password
################################################################################

resource "aws_secretsmanager_secret_version" "digital_wallet_pass" {
  secret_id     = module.secrets["digital_wallet_secret"].id  # Reference the secret from the secrets module
  secret_string = jsonencode({
    username = var.dw_rds_username
    password = random_password.password.result  # Use the generated password
  })

  # Ensure the secret is created first and password is generated before injecting into the secret
  depends_on = [
    module.secrets["digital_wallet_secret"],  # Ensure the secret is created
    random_password.password                  # Ensure the password is generated before use
  ]
}

################################################################################
# Fetch Secret Version from AWS Secrets Manager
################################################################################

data "aws_secretsmanager_secret_version" "digital_wallet_pass" {
  secret_id = module.secrets["digital_wallet_secret"].id  # Reference the secret from the secrets module

  # Ensure the secret version is available after it's created
  depends_on = [
    aws_secretsmanager_secret_version.digital_wallet_pass  # Ensure secret version is available
  ]
}

################################################################################
# Digital Wallet (Bitpanda) - RDS Resources
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

  # Inject the username and password from the secret version
  username = jsondecode(data.aws_secretsmanager_secret_version.digital_wallet_pass.secret_string)["username"]
  password = jsondecode(data.aws_secretsmanager_secret_version.digital_wallet_pass.secret_string)["password"]

  # Ensure the RDS module runs after the secret is created and the password is injected
  depends_on = [
    aws_secretsmanager_secret_version.digital_wallet_pass
  ]
}
