# Defines the required Terraform CLI version and AWS provider version.
terraform {
  required_version = ">= 1.12.1" # Matches your CI/CD Terraform version
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Use a compatible AWS provider version
    }
  }
}

# AWS Provider configuration for global resources.
# IAM is a global service, but Terraform providers still require a region.
# us-east-1 is a common choice for managing global resources.
provider "aws" {
  region = "us-east-1"
}

# Create the Secret Manager resource AND populate it with the initial value
module "my_example_api_key" {
  source             = "../modules/secretsmanager"
  secret_name        = "${var.environment}-MyApiKey"
  secret_description = "API Key for My App. Value populated via CI/CD."
  environment        = var.environment
  secret_value       = var.example_api_key_value # Pass the sensitive value here
}

#Create a second API Key with a dummy initial value for manual management
module "my_manual_api_key" {
  source             = "../modules/secretsmanager"
  secret_name        = "${var.environment}-MyManualApiKey"
  secret_description = "API Key for a service, value managed manually via CLI/Console."
  environment        = var.environment
  secret_value       = "dummy-initial-value-for-manual-update" # Provide a dummy string
}

# Instantiate the IAM Policy module to create the EC2 Instance Connect Policy
module "ec2_instance_connect_policy" {
  source             = "../modules/iam_policy"
  policy_name        = "${var.environment}-EC2InstanceConnectAccess"
  policy_description = "Grants permissions for EC2 Instance Connect"
  environment        = var.environment
  statements = [
    {
      sid       = "EC2InstanceConnectSSH"
      actions   = ["ec2-instance-connect:SendSSHPublicKey"]
      resources = ["arn:aws:ec2:${var.region}:*:instance/*"] # Scope to instances in us-east-1 for now, or use "*" for all regions
      # If you want to restrict to specific instances later:
      # resources = ["arn:aws:ec2:${var.region}:<account_id>:instance/<instance_id>"]
    },
    {
      sid       = "EC2DescribeInstances"
      actions   = ["ec2:DescribeInstances"]
      resources = ["*"] # ec2:DescribeInstances is a read-only permission and doesn't support resource-level permissions often.
    }
  ]
}

# Instantiate the IAM Policy module to create the S3/SQS List Access Policy.
# Source path is relative from 'terraform/global/' to 'terraform/modules/iam_policy/'.
module "s3_sqs_list_policy" {
  source             = "../modules/iam_policy" # Correct relative path
  policy_name        = "${var.environment}-s3-sqs-list-access"
  policy_description = "Grants ListBucket on S3 and ListQueues on SQS"
  environment        = var.environment
  statements = [
    {
      sid       = "S3ListAccess"
      actions   = ["s3:ListBucket"]
      resources = ["arn:aws:s3:::*"] # Allows listing all buckets
    },
    {
      sid       = "SQSListAccess"
      actions   = ["sqs:ListQueues"]
      resources = ["*"] # Allows listing all SQS queues
    }
  ]
}

# Instantiate the IAM User module to create the "prod" user.
# Source path is relative from 'terraform/global/' to 'terraform/modules/iam_user/'.
module "prod_user" {
  source      = "../modules/iam_user" # Correct relative path
  user_name   = "${var.environment}-prod-user"
  environment = var.environment
  policy_arns = [
    module.s3_sqs_list_policy.policy_arn,         # Attach the policy created above
    module.ec2_instance_connect_policy.policy_arn # Attach EC2 instance connect policy
  ]
}

# Instantiate the IAM User module to create the "dev" user.
module "dev_user" {
  source      = "../modules/iam_user" # Correct relative path
  user_name   = "${var.environment}-dev-user"
  environment = var.environment
  policy_arns = [
    module.s3_sqs_list_policy.policy_arn,         # Attach the same policy
    module.ec2_instance_connect_policy.policy_arn # Attach EC2 instance connect policy
  ]
}

# outpts for api_key 
# This output is only for demonstration. Do not output sensitive data in a real project.
output "example_api_key_secret_arn" {
  value       = module.my_example_api_key.secret_arn
  description = "The ARN of the example API key secret."
}
# Output for the  API_key with a dummy initial value
output "manual_api_key_secret_arn" {
  value       = module.my_manual_api_key.secret_arn
  description = "The ARN of the manually managed API key secret."
}

# Outputs for user credentials.
# These are marked sensitive and should be handled with extreme care!
# In a real-world scenario, you would integrate with a secrets manager.
output "prod_user_access_key_id" {
  value       = module.prod_user.access_key_id
  description = "Access Key ID for the 'prod' user."
  sensitive   = true
}
output "prod_user_secret_access_key" {
  value       = module.prod_user.secret_access_key
  description = "Secret Access Key for the 'prod' user."
  sensitive   = true
}

output "dev_user_access_key_id" {
  value       = module.dev_user.access_key_id
  description = "Access Key ID for the 'dev' user."
  sensitive   = true
}
output "dev_user_secret_access_key" {
  value       = module.dev_user.secret_access_key
  description = "Secret Access Key for the 'dev' user."
  sensitive   = true
}
