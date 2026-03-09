aws_region = "us-east-1"

# Key pair configuration specific to us-east-1
regional_key_pair = {
  key_name   = "us_key_one"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCdj0+BeXaMVMo1pFsc0Njbu1ToHhyPzn69WyDfG2Jp2SGC3qST0DONRkC0u8KRGtlfuF76sUJ2RZfeE3oLYvA/+S0pLJ4B/oT6EIxaWBhiiV0i2VFNfAyj234Bsmc4SkGnGjxFsjccu54zKgKiSi9acpjRI75hxzMnRo9ooXIYItH1nZxfnx5ngvJY09ntHZJExLue9H0vLyNr4rhrCwRsvRyDV7iw76ahOC5/fY2SxBc4MRZ8ol1FT3iFnwNaBOesy+XFQhi+7rct/Fda0Z8XC186iY1OPgMkGMesM7M4UbS+BRSdvN3p8eMxhDp+68J4ctbe6h/LYVQJaYKvF0t9"
}

# IMPORTANT: Choose an AMI specific to the region and instance type.
# Always verify the latest AMIs in the AWS console, as these examples might be outdated.
ec2_ami_id        = "ami-053b0d53c279acc90" # Example: Amazon Linux 2023 for us-east-1
environment       = "dev"
ec2_instance_type = "t2.micro" # Explicitly setting, or rely on default in variables.tf

# Network Configuration
vpc_cidr_block        = "10.0.0.0/16"
app_subnet_cidr_block = "10.0.1.0/24"
db_subnet_cidr_block  = "10.0.2.0/24"
az_suffix             = "a" # Use 'a' for us-east-1a

# Security Configuration
# IMPORTANT: Replace with your actual public IP. You can find it by searching "what is my ip"
allowed_ssh_cidr_blocks = ["0.0.0.0/0"] # e.g., ["203.0.113.10/32"]