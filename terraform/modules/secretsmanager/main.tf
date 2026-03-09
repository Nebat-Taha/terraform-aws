# This resource defines the secret itself, including its name, description, and tags.

resource "aws_secretsmanager_secret" "this" {
  name        = var.secret_name
  description = var.secret_description

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


# This resource stores a version of the secret.
resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = var.secret_value

  # This is the 'ignore_changes' block you asked about.
  # It tells Terraform to ignore any changes to the secret's value
  # after it has been created, allowing AWS Secrets Manager's
  # automated rotation process to take over without causing a plan to drift.
  lifecycle {
    ignore_changes = [
      secret_string,
    ]
  }
}
