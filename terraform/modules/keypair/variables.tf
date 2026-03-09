variable "key_name" {
  description = "The name for the EC2 SSH Key Pair."
  type        = string
}

variable "public_key" {
  description = "The public key material for the EC2 Key Pair."
  type        = string
  sensitive   = true # Mark as sensitive to prevent logging
}