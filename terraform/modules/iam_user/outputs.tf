output "user_arn" {
  value       = aws_iam_user.this.arn
  description = "The ARN (Amazon Resource Name) of the created IAM user."
}

output "user_name" {
  value       = aws_iam_user.this.name
  description = "The name of the created IAM user."
}

output "access_key_id" {
  value       = aws_iam_access_key.this.id
  description = "The ID of the access key generated for the user."
  sensitive   = true # Mark as sensitive: Terraform will hide this in logs and CLI output.
}

output "secret_access_key" {
  value       = aws_iam_access_key.this.secret
  description = "The secret access key generated for the user."
  sensitive   = true # Mark as sensitive: Terraform will hide this in logs and CLI output.
}