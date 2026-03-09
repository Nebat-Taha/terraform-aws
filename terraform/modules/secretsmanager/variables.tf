variable "secret_name" {
  description = "The name of the secret in Secrets Manager."
  type        = string
}

variable "secret_description" {
  description = "A description for the secret."
  type        = string
}

variable "secret_value" {
  description = "The actual sensitive value of the API key."
  type        = string
  sensitive   = true # VERY IMPORTANT: Marks the variable as sensitive.
}

variable "environment" {
  description = "The environment name for tagging the secret."
  type        = string
}
