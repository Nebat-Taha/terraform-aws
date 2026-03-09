variable "environment" {
  description = "The environment name for global resources (e.g., dev, prod)."
  type        = string
  default     = "dev" # Default for now, can be overridden via tfvars or CI/CD
}

# define the example_api_key_value variable
variable "example_api_key_value" {
  description = "The actual value of the example API key, injected via CI/CD."
  type        = string
  sensitive   = true # Marks the variable as sensitive
}

variable "region" {
  description = "The AWS region for global resources (e.g., us-east-1)."
  type        = string
  default     = "us-east-1" # Often set to us-east-1 for global resources
}
