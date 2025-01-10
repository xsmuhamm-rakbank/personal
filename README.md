################################################################################
# Digital Wallet (Bitpanda) RDS Outputs
################################################################################

output "dw_db_instance_address" {
  description = "The address of the RDS instance"
  value       = module.digital_wallet.db_instance_address
}

output "dw_db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = module.digital_wallet.db_instance_arn
}

output "dw_db_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = module.digital_wallet.db_instance_availability_zone
}

output "dw_db_instance_endpoint" {
  description = "The connection endpoint"
  value       = module.digital_wallet.db_instance_endpoint
}

output "dw_db_instance_engine" {
  description = "The database engine"
  value       = module.digital_wallet.db_instance_engine
}

output "dw_db_instance_engine_version_actual" {
  description = "The running version of the database"
  value       = module.digital_wallet.db_instance_engine_version_actual
}

output "dw_db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = module.digital_wallet.db_instance_hosted_zone_id
}

output "dw_db_instance_identifier" {
  description = "The RDS instance identifier"
  value       = module.digital_wallet.db_instance_identifier
}

output "dw_db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = module.digital_wallet.db_instance_resource_id
}

output "dw_db_instance_status" {
  description = "The RDS instance status"
  value       = module.digital_wallet.db_instance_status
}

output "dw_db_instance_name" {
  description = "The database name"
  value       = module.digital_wallet.dw_db_name
}

output "dw_db_instance_username" {
  description = "The master username for the database"
  value       = module.digital_wallet.dw_rds_username
  sensitive   = true
}

output "dw_db_instance_port" {
  description = "The database port"
  value       = module.digital_wallet.db_instance_port
}

output "dw_db_subnet_group_id" {
  description = "The db subnet group name"
  value       = module.digital_wallet.db_subnet_group_id
}

output "dw_db_subnet_group_arn" {
  description = "The ARN of the db subnet group"
  value       = module.digital_wallet.db_subnet_group_arn
}

output "dw_db_parameter_group_id" {
  description = "The db parameter group id"
  value       = module.digital_wallet.db_parameter_group_id
}

output "dw_db_parameter_group_arn" {
  description = "The ARN of the db parameter group"
  value       = module.digital_wallet.db_parameter_group_arn
}

output "dw_db_instance_cloudwatch_log_groups" {
  description = "Map of CloudWatch log groups created and their attributes"
  value       = module.digital_wallet.db_instance_cloudwatch_log_groups
}

output "dw_db_instance_master_user_secret_arn" {
  description = "The ARN of the master user secret (Only available when manage_master_user_password is set to true)"
  value       = module.digital_wallet.db_instance_master_user_secret_arn
}

output "dw_db_instance_secretsmanager_secret_rotation_enabled" {
  description = "Specifies whether automatic rotation is enabled for the secret"
  value       = module.digital_wallet.db_instance_secretsmanager_secret_rotation_enabled
}


variable "dw_db_ingress_cidr_blocks" {
  description = "CIDR block for Digital Wallet RDS"
  type        = list(string)
  default     = []
}

