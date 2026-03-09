output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the created VPC."
}

output "app_subnet_id" {
  value       = aws_subnet.app.id
  description = "The ID of the application subnet."
}

output "db_subnet_id" {
  value       = aws_subnet.db.id
  description = "The ID of the database subnet."
}