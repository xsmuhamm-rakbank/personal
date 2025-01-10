Validation failed: .
╷
│ Error: Unsupported attribute
│ 
│   on outputs.tf line 312, in output "dw_db_instance_name":
│  312:   value       = module.digital_wallet.dw_db_name
│     ├────────────────
│     │ module.digital_wallet is a object
│ 
│ This object does not have an attribute named "dw_db_name".
╵
╷
│ Error: Unsupported attribute
│ 
│   on outputs.tf line 317, in output "dw_db_instance_username":
│  317:   value       = module.digital_wallet.dw_rds_username
│     ├────────────────
│     │ module.digital_wallet is a object
│ 
│ This object does not have an attribute named "dw_rds_username".
╵
