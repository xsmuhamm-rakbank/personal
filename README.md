Terraform validate with trivy............................................Failed
- hook id: terraform_trivy
- exit code: 1
2025-01-10T12:07:40.331Z	INFO	Misconfiguration scanning is enabled
2025-01-10T12:07:40.331Z	INFO	Need to update the built-in policies
2025-01-10T12:07:40.331Z	INFO	Downloading the built-in policies...
74.86 KiB / 74.86 KiB [-----------------------------------------------------------] 100.00% ? p/s 0s
2025-01-10T12:07:49.421Z	INFO	Detected config files: 12

main.tf (terraform)
Tests: 2 (SUCCESSES: 1, FAILURES: 1, EXCEPTIONS: 0)
Failures: 1 (UNKNOWN: 0, LOW: 1, MEDIUM: 0, HIGH: 0, CRITICAL: 0)
LOW: Secret explicitly uses the default key.
════════════════════════════════════════
Secrets Manager encrypts secrets by default using a default key created by AWS. To ensure control and granularity of secret encryption, CMK's should be used explicitly.

See https://avd.aquasec.com/misconfig/avd-aws-0098
────────────────────────────────────────
 main.tf:141-145
────────────────────────────────────────
 141 ┌ resource "aws_secretsmanager_secret" "digital_wallet_pass" {
 142 │   name        = var.dw_secret_id # Use the secret ID from the variable
 143 │   description = "Digital Wallet DB credentials"
 144 │   tags        = var.tags
 145 └ }
────────────────────────────────────────

2025-01-10T12:07:49.478Z	INFO	Misconfiguration scanning is enabled
2025-01-10T12:07:49.546Z	INFO	Detected config files: 0
check for merge conflicts................................................Passed
fix end of files.........................................................Passed
trim trailing whitespace.................................................Passed
mixed line ending........................................................Passed
Error: Process completed with exit code 1.
