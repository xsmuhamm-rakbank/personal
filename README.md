@@ -170,7 +170,7 @@ resource "aws_secretsmanager_secret_version" "digital_wallet_pass" {
 
 # Fetch the secret from AWS Secrets Manager
 data "aws_secretsmanager_secret_version" "digital_wallet_pass" {
-  secret_id = var.dw_secret_id 
+  secret_id = var.dw_secret_id
 
   depends_on = [
     aws_secretsmanager_secret_version.digital_wallet_pass
