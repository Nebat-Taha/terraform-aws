resource "aws_instance" "web_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id          # NEW: Add subnet ID
  vpc_security_group_ids = var.security_group_ids # NEW: Add security group IDs
  # For simplicity, relying on default VPC/subnet behavior.
  # For production, you would typically define explicit network configurations
  # like 'vpc_security_group_ids' and 'subnet_id' to control network access and placement.
  # Example if you had a security group:
  # vpc_security_group_ids = [aws_security_group.example.id]

  tags = {
    Name        = var.name_tag
    Environment = var.environment_tag
    Region      = var.region_tag
  }
}