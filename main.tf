resource "random_password" "password" {
  length           = 16
  special          = false
  override_special = true
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
}

Warning: Missing version constraint for provider "random" in `required_providers` (terraform_required_providers)
  on main.tf line 139:
 139: resource "random_password" "password" {
Reference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.5.0/docs/rules/terraform_required_providers.md
Terraform validate................................
