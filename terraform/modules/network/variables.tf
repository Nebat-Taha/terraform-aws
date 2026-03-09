variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "app_subnet_cidr_block" {
  description = "The CIDR block for the application subnet."
  type        = string
}

variable "db_subnet_cidr_block" {
  description = "The CIDR block for the database subnet."
  type        = string
}

variable "aws_region" {
  description = "The AWS region where resources will be deployed."
  type        = string
}

variable "az_suffix" {
  description = "The availability zone suffix (e.g., 'a' for us-east-1a)."
  type        = string
  default     = "a" # Can be made dynamic or chosen based on region needs
}

variable "environment" {
  description = "The environment name (e.g., dev, prod)."
  type        = string
}