variable "policy_name" {
  description = "The name of the IAM policy."
  type        = string
}

variable "policy_description" {
  description = "The description of the IAM policy."
  type        = string
  default     = "Managed by Terraform"
}

variable "statements" {
  description = "A list of policy statements to include in the policy document."
  type = list(object({
    sid       = optional(string)
    actions   = list(string)
    resources = list(string)
    effect    = optional(string, "Allow")
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })), [])
    # REMOVED the 'conditions' block from here for now, as it caused the error
    # and is not currently used in your S3/SQS policy.
    # If you need to add conditions later, we will revisit their specific type definition.
  }))
}

variable "environment" {
  description = "The environment name for tagging the IAM policy."
  type        = string
}