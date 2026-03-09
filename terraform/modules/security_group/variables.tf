variable "vpc_id" {
  description = "The ID of the VPC to create the security group in."
  type        = string
}

variable "sg_name" {
  description = "The name suffix for the security group."
  type        = string
}

variable "sg_description" {
  description = "The description for the security group."
  type        = string
  default     = "Security group for SSH access"
}

variable "allowed_cidr_blocks" {
  description = "A list of CIDR blocks to allow ingress from."
  type        = list(string)
  default     = ["0.0.0.0/0"] # WARNING: In a production environment, restrict this to your specific IP or VPN CIDR
}

variable "environment" {
  description = "The environment name (e.g., dev, prod)."
  type        = string
}

variable "aws_region" {
  description = "The AWS region where resources will be deployed."
  type        = string
}