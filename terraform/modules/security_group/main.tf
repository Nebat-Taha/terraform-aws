resource "aws_security_group" "ssh_sg" {
  name        = "${var.environment}-${var.sg_name}-${var.aws_region}"
  description = var.sg_description
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks # Make this configurable for your IP
    description = "Allow SSH access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.environment}-${var.sg_name}-${var.aws_region}"
    Environment = var.environment
    Region      = var.aws_region
  }
}