output "secret_arn" {
  value       = aws_secretsmanager_secret.this.arn
  description = "The ARN of the created Secrets Manager secret."
}

output "secret_name" {
  value       = aws_secretsmanager_secret.this.name
  description = "The name of the created Secrets Manager secret."
}
