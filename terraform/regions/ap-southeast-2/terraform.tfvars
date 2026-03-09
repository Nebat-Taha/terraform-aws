aws_region = "ap-southeast-2"

# Key pair configuration specific to ap-southeast-2
regional_key_pair = {
  key_name   = "sydney_key_one"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCdj0+BeXaMVMo1pFsc0Njbu1ToHhyPzn69WyDfG2Jp2SGC3qST0DONRkC0u8KRGtlfuF76sUJ2RZfeE3oLYvA/+S0pLJ4B/oT6EIxaWBhiiV0i2VFNfAyj234Bsmc4SkGnGjxFsjccu54zKgKiSi9acpjRI75hxzMnRo9ooXIYItH1nZxfnx5ngvJY09ntHZJExLue9H0vLyNr4rhrCwRsvRyDV7iw76ahOC5/fY2SxBc4MRZ8ol1FT3iFnwNaBOesy+XFQhi+7rct/Fda0Z8XC186iY1OPgMkGMesM7M4UbS+BRSdvN3p8eMxhDp+68J4ctbe6h/LYVQJaYKvF0t9"
}
# Network Configuration - UNIQUE CIDR BLOCK for ap-southeast-2
vpc_cidr_block        = "10.1.0.0/16" # Example: VPC will get 10.1.0.0 - 10.1.255.255
app_subnet_cidr_block = "10.1.1.0/24" # Example: App Subnet will get 10.1.1.0 - 10.1.1.255
db_subnet_cidr_block  = "10.1.2.0/24" # Example: DB Subnet will get 10.1.2.0 - 10.1.2.255
az_suffix             = "a"

# Security Configuration
# IMPORTANT: Replace with your actual public IP. You can find it by searching "what is my ip"
allowed_ssh_cidr_blocks = ["0.0.0.0/0"] # e.g., ["203.0.113.10/32"]