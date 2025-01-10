  I think secret for storing db password should be created in the first apply.
RDS changes should be done in the second apply. 
Or can we add a dependency for random password with AWS secret module ?
Both methods are fine,  try to add dependency as per above suggestion. and share PR. Secrets should be available before injecting random password string in it. 


### Digital Wallet(Bitpanda) - RDS ###


resource "random_password" "password" {
  length           = 16
  special          = false
  override_special = true
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
}

resource "aws_secretsmanager_secret_version" "digital_wallet_pass" {
  secret_id = var.dw_secret_id
  secret_string = jsonencode({
    username = var.dw_rds_username
    password = random_password.password.result
  })
}

data "aws_secretsmanager_secret_version" "digital_wallet_pass" {
  secret_id = var.dw_secret_id

  depends_on = [aws_secretsmanager_secret_version.digital_wallet_pass]
}


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


  depends_on = [
    aws_secretsmanager_secret_version.digital_wallet_pass
  ]
}
