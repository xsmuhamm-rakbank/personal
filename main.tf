1- Outputs should be enable for new RDS module.
2- Create Secret for DB password
3- For db_subnet_group_name, let it be same as VPC is same.
4- db_ingress_cidr_blocks make it separate and clone values from DEH RDS, on requirement one can update

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


  username = jsondecode(data.aws_secretsmanager_secret_version.digital_wallet_pass.secret_string)["username"]
  password = jsondecode(data.aws_secretsmanager_secret_version.digital_wallet_pass.secret_string)["password"]


  depends_on = [
    aws_secretsmanager_secret_version.digital_wallet_pass
  ]
}


tfvars develop

subnets = ["subnet-016a90028714de462", "subnet-05cb126b31e6dba8a", "subnet-01faf667f57e784a7"]


db_ingress_cidr_blocks     = ["10.85.128.0/20", "10.85.201.8/32", "10.85.201.10/32", "10.85.184.0/23", "10.85.139.177/32", "10.85.201.54/32"]
engine_version             = "16.3"
family                     = "postgres16"
major_engine_version       = "16.3"
port                       = 5500
multi_az                   = true
allocated_storage          = 500
max_allocated_storage      = 550
storage_type               = "gp3"
apply_immediately          = true
deletion_protection        = true
db_subnet_group_name       = "deh-db-dev-01-subnet-group"
auto_minor_version_upgrade = false
create_replica             = true
replica_count              = 0

force_ssl = "0"

################################################################################
# RDS Postgres Module Values
################################################################################

db_name        = "deh-db-dev-01"
instance_class = "db.m5.2xlarge"
secret_id      = "deh-db-dev-01-secret"

################################################################################
# Digital Wallet RDS Postgres Module Values
################################################################################

dw_db_name        = "da_dev_rds_db"
dw_instance_class = "db.m5.large"
dw_rds_username   = "postgres"
dw_secret_id      = "digital-wallet-secret"
