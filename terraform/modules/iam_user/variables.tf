variable "user_name" {
  description = "The name for the IAM user to be created."
  type        = string
}

variable "environment" {
  description = "The environment name for tagging the IAM user (e.g., dev, prod)."
  type        = string
}

variable "policy_arns" {
  description = "A list of ARNs of IAM policies to attach to the user."
  type        = list(string)
  default     = [] # Default to an empty list if no policies are specified
}