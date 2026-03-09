output "security_group_id" {
  value       = aws_security_group.ssh_sg.id
  description = "The ID of the created SSH security group."
} 