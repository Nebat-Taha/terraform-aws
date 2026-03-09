resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.environment}-vpc-${var.aws_region}"
    Environment = var.environment
    Region      = var.aws_region
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-igw-${var.aws_region}"
    Environment = var.environment
    Region      = var.aws_region
  }
}

resource "aws_subnet" "app" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.app_subnet_cidr_block
  availability_zone       = "${var.aws_region}${var.az_suffix}" # Example: us-east-1a
  map_public_ip_on_launch = true                                # EC2 instances in this subnet will get a public IP

  tags = {
    Name        = "${var.environment}-app-subnet-${var.aws_region}"
    Environment = var.environment
    Region      = var.aws_region
  }
}

resource "aws_subnet" "db" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_subnet_cidr_block
  availability_zone = "${var.aws_region}${var.az_suffix}" # Example: us-east-1a (can be different AZ if desired)

  tags = {
    Name        = "${var.environment}-db-subnet-${var.aws_region}"
    Environment = var.environment
    Region      = var.aws_region
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.environment}-public-rt-${var.aws_region}"
    Environment = var.environment
    Region      = var.aws_region
  }
}

resource "aws_route_table_association" "app_subnet_association" {
  subnet_id      = aws_subnet.app.id
  route_table_id = aws_route_table.public.id
}