terraform {
  required_version = ">=1.12.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}
# Define the AWS provider for this specific region
provider "aws" {
  region = var.aws_region
}

# Call the shared key_pair module using the regional_key_pair variable
module "regional_key_pair" {
  source     = "../../modules/keypair" # Adjust path as needed
  key_name   = var.regional_key_pair.key_name
  public_key = var.regional_key_pair.public_key
}

# Example: Using the key pair with an EC2 instance (assuming you have an ec2_instance module)
/*
module "my_ec2_instance" {
  source = "../../modules/ec2_instance" # Adjust path as needed
  # ... other EC2 inputs
  key_name = module.regional_key_pair.key_pair_name
}
*/
module "vpc_network" {
  source                = "../../modules/network"
  vpc_cidr_block        = var.vpc_cidr_block
  app_subnet_cidr_block = var.app_subnet_cidr_block
  db_subnet_cidr_block  = var.db_subnet_cidr_block
  aws_region            = var.aws_region
  az_suffix             = var.az_suffix # Pass the AZ suffix for subnet placement
  environment           = var.environment
}

module "ssh_security_group" {
  source              = "../../modules/security_group"
  vpc_id              = module.vpc_network.vpc_id # Depends on the network module
  sg_name             = "allow-ssh"
  sg_description      = "Allows SSH access from specified CIDR blocks"
  allowed_cidr_blocks = var.allowed_ssh_cidr_blocks # Define this in regional variables/tfvars
  environment         = var.environment
  aws_region          = var.aws_region
}

output "vpc_id" {
  value       = module.vpc_network.vpc_id
  description = "The ID of the VPC."
}

output "app_subnet_id" {
  value       = module.vpc_network.app_subnet_id
  description = "The ID of the application subnet."
}

output "db_subnet_id" {
  value       = module.vpc_network.db_subnet_id
  description = "The ID of the database subnet."
}

output "ssh_security_group_id" {
  value       = module.ssh_security_group.security_group_id
  description = "The ID of the SSH Security Group."
}

