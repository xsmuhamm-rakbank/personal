Error: Duplicate output definition
│ 
│   on outputs.tf line 260:
│  260: output "db_instance_address" {
│ 
│ An output named "db_instance_address" was already defined at
│ outputs.tf:128,1-29. Output names must be unique within a module.
╵

╷
│ Error: Duplicate output definition
│ 
│   on outputs.tf line 265:
│  265: output "db_instance_arn" {
│ 
│ An output named "db_instance_arn" was already defined at
│ outputs.tf:133,1-25. Output names must be unique within a module.
╵

╷
│ Error: Duplicate output definition
│ 
│   on outputs.tf line 270:
│  270: output "db_instance_availability_zone" {
│ 
│ An output named "db_instance_availability_zone" was already defined at
│ outputs.tf:138,1-39. Output names must be unique within a module.
╵

╷
│ Error: Duplicate output definition
│ 
│   on outputs.tf line 275:
│  275: output "db_instance_endpoint" {
│ 
│ An output named "db_instance_endpoint" was already defined at
│ outputs.tf:143,1-30. Output names must be unique within a module.
╵

╷
│ Error: Duplicate output definition
│ 
│   on outputs.tf line 280:
│  280: output "db_instance_engine" {
│ 
│ An output named "db_instance_engine" was already defined at
│ outputs.tf:148,1-28. Output names must be unique within a module.
╵

╷
│ Error: Duplicate output definition
│ 
│   on outputs.tf line 285:
│  285: output "db_instance_engine_version_actual" {
│ 
│ An output named "db_instance_engine_version_actual" was already defined at
│ outputs.tf:153,1-43. Output names must be unique within a module.
╵

╷
│ Error: Duplicate output definition
│ 
│   on outputs.tf line 290:
│  290: output "db_instance_hosted_zone_id" {
│ 
│ An output named "db_instance_hosted_zone_id" was already defined at
│ outputs.tf:158,1-36. Output names must be unique within a module.
╵

╷
│ Error: Duplicate output definition
│ 
│   on outputs.tf line 295:
│  295: output "db_instance_identifier" {
│ 
│ An output named "db_instance_identifier" was already defined at
│ outputs.tf:163,1-32. Output names must be unique within a module.
╵

╷
│ Error: Duplicate output definition
│ 
│   on outputs.tf line 300:
│  300: output "db_instance_resource_id" {
│ 
│ An output named "db_instance_resource_id" was already defined at
│ outputs.tf:168,1-33. Output names must be unique within a module.
╵

╷
│ Error: Duplicate output definition
│ 
│   on outputs.tf line 305:
│  305: output "db_instance_status" {
│ 
│ An output named "db_instance_status" was already defined at
│ outputs.tf:173,1-28. Output names must be unique within a module.
╵

╷
│ Error: Duplicate output definition
│ 
│   on outputs.tf line 310:
│  310: output "db_instance_name" {
│ 
│ An output named "db_instance_name" was already defined at
│ outputs.tf:178,1-26. Output names must be unique within a module.
╵

╷
│ Error: Duplicate output definition
│ 
│   on outputs.tf line 315:
│  315: output "db_instance_username" {
│ 
│ An output named "db_instance_username" was already defined at
│ outputs.tf:183,1-30. Output names must be unique within a module.
╵

╷
│ Error: Duplicate output definition
│ 
│   on outputs.tf line 321:
│  321: output "db_instance_port" {
│ 
│ An output named "db_instance_port" was already defined at
│ outputs.tf:189,1-26. Output names must be unique within a module.
╵

╷
│ Error: Duplicate output definition
│ 
│   on outputs.tf line 326:
│  326: output "db_subnet_group_id" {
│ 
│ An output named "db_subnet_group_id" was already defined at
│ outputs.tf:194,1-28. Output names must be unique within a module.
╵

╷
│ Error: Duplicate output definition
│ 
│   on outputs.tf line 331:
│  331: output "db_subnet_group_arn" {
│ 
│ An output named "db_subnet_group_arn" was already defined at
│ outputs.tf:199,1-29. Output names must be unique within a module.
╵

╷
│ Error: Duplicate output definition
│ 
│   on outputs.tf line 336:
│  336: output "db_parameter_group_id" {
│ 
│ An output named "db_parameter_group_id" was already defined at
│ outputs.tf:204,1-31. Output names must be unique within a module.
╵

╷
│ Error: Duplicate output definition
│ 
│   on outputs.tf line 341:
│  341: output "db_parameter_group_arn" {
│ 
│ An output named "db_parameter_group_arn" was already defined at
│ outputs.tf:209,1-32. Output names must be unique within a module.
╵

╷
│ Error: Duplicate output definition
│ 
│   on outputs.tf line 347:
│  347: output "db_instance_cloudwatch_log_groups" {
│ 
│ An output named "db_instance_cloudwatch_log_groups" was already defined at
│ outputs.tf:219,1-43. Output names must be unique within a module.
╵

╷
│ Error: Duplicate output definition
│ 
│   on outputs.tf line 352:
│  352: output "db_instance_master_user_secret_arn" {
│ 
│ An output named "db_instance_master_user_secret_arn" was already defined at
│ outputs.tf:224,1-44. Output names must be unique within a module.
╵

╷
│ Error: Duplicate output definition
│ 
│   on outputs.tf line 357:
│  357: output "db_instance_secretsmanager_secret_rotation_enabled" {
│ 
│ An output named "db_instance_secretsmanager_secret_rotation_enabled" was
│ already defined at outputs.tf:229,1-60. Output names must be unique within
│ a module.
╵

╷
│ Error: Invalid variable name
│ 
│   on variables.tf line 330, in variable "dw_db_ingress_cidr_blocks ":
│  330: variable "dw_db_ingress_cidr_blocks " {
│ 
│ A name must start with a letter or underscore and may contain only letters,
│ digits, underscores, and dashes.
╵
################################################################################
# Digital Wallet (Bitpanda) RDS Outputs
################################################################################

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = module.digital_wallet.db_instance_address
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = module.digital_wallet.db_instance_arn
}

output "db_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = module.digital_wallet.db_instance_availability_zone
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = module.digital_wallet.db_instance_endpoint
}

output "db_instance_engine" {
  description = "The database engine"
  value       = module.digital_wallet.db_instance_engine
}

output "db_instance_engine_version_actual" {
  description = "The running version of the database"
  value       = module.digital_wallet.db_instance_engine_version_actual
}

output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = module.digital_wallet.db_instance_hosted_zone_id
}

output "db_instance_identifier" {
  description = "The RDS instance identifier"
  value       = module.digital_wallet.db_instance_identifier
}

output "db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = module.digital_wallet.db_instance_resource_id
}

output "db_instance_status" {
  description = "The RDS instance status"
  value       = module.digital_wallet.db_instance_status
}

output "db_instance_name" {
  description = "The database name"
  value       = module.digital_wallet.dw_db_name
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = module.digital_wallet.dw_rds_username
  sensitive   = true
}

output "db_instance_port" {
  description = "The database port"
  value       = module.digital_wallet.db_instance_port
}

output "db_subnet_group_id" {
  description = "The db subnet group name"
  value       = module.digital_wallet.db_subnet_group_id
}

output "db_subnet_group_arn" {
  description = "The ARN of the db subnet group"
  value       = module.digital_wallet.db_subnet_group_arn
}

output "db_parameter_group_id" {
  description = "The db parameter group id"
  value       = module.digital_wallet.db_parameter_group_id
}

output "db_parameter_group_arn" {
  description = "The ARN of the db parameter group"
  value       = module.digital_wallet.db_parameter_group_arn
}


output "db_instance_cloudwatch_log_groups" {
  description = "Map of CloudWatch log groups created and their attributes"
  value       = module.digital_wallet.db_instance_cloudwatch_log_groups
}

output "db_instance_master_user_secret_arn" {
  description = "The ARN of the master user secret (Only available when manage_master_user_password is set to true)"
  value       = module.digital_wallet.db_instance_master_user_secret_arn
}

output "db_instance_secretsmanager_secret_rotation_enabled" {
  description = "Specifies whether automatic rotation is enabled for the secret"
  value       = module.digital_wallet.db_instance_secretsmanager_secret_rotation_enabled
}



variable "dw_db_ingress_cidr_blocks " {
  description = "cidr block for digital wallet rds"
  type        = list(string)
  default     = []
}
