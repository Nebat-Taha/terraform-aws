variable "ami_id" {
  description = "The AMI ID for the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instance."
  type        = string
  default     = "t2.micro" # As requested
}

variable "key_name" {
  description = "The name of the key pair to use for the EC2 instance."
  type        = string
}

variable "name_tag" {
  description = "The value for the Name tag of the EC2 instance."
  type        = string
}

variable "environment_tag" {
  description = "The value for the Environment tag of the EC2 instance."
  type        = string
}

variable "region_tag" {
  description = "The value for the Region tag of the EC2 instance."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to launch the EC2 instance into."
  type        = string
}

variable "security_group_ids" {
  description = "A list of security group IDs to attach to the EC2 instance."
  type        = list(string)
  default     = [] # Default to empty list if no security groups are provided
}