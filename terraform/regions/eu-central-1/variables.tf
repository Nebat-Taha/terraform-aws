variable "aws_region" {
  description = "The AWS region to deploy resources into."
  type        = string
}

variable "regional_key_pair" {
  description = "Configuration for the key pair in this specific region."
  type = object({
    key_name   = string
    public_key = string
  })
}

variable "environment" {
  description = "The environment name (e.g., dev, prod, test)."
  type        = string
  default     = "dev"
}
variable "vpc_cidr_block" {
  description = "The CIDR block for the main VPC."
  type        = string
  default     = "10.2.0.0/16" # Example
}
variable "app_subnet_cidr_block" {
  description = "The CIDR block for the application subnet."
  type        = string
  default     = "10.2.1.0/24" # Example
}

variable "db_subnet_cidr_block" {
  description = "The CIDR block for the database subnet."
  type        = string
  default     = "10.2.2.0/24" # Example
}

variable "az_suffix" {
  description = "The availability zone suffix (e.g., 'a' for us-east-1a)."
  type        = string
  default     = "a"
}

variable "allowed_ssh_cidr_blocks" {
  description = "A list of CIDR blocks that are allowed to SSH into instances."
  type        = list(string)
  # IMPORTANT: Replace "YOUR_PUBLIC_IP_HERE/32" with your actual public IP address
  # or remove this default and set it in terraform.tfvars for production.
  default = ["0.0.0.0/0"] # WARNING: Wide open! Restrict this to your actual IP!
}