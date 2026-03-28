
# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-${var.project_name}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-${var.project_name}-igw"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
    subnet_id = aws_subnet.public_az1.id
    allocation_id = aws_eip.eip.id
}

# EIP for NAT Gateway
resource "aws_eip" "eip" {
    domain = "vpc"

    tags = {
        Name = "${var.environment}-${var.project_name}-nat-eip"
    }
    # Ensure the NAT Gateway is created after the Internet Gateway
    depends_on = [aws_internet_gateway.igw]
}


# Get avaiable AZs in the region
data "aws_availability_zones" "available_zones" {}

# Public Subnet 1
resource "aws_subnet" "public_az1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_az1_cidr
  availability_zone = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-${var.project_name}-public-subnet-az1"
    Type        = "public"
  }
}

# Public Subnet 2
resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_az2_cidr
  availability_zone = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-${var.project_name}-public-subnet-az2"
    Type        = "public"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
  tags = {
    Name = "${var.environment}-${var.project_name}-public-rtb"
  }
}

# Route Table Association for Public Subnets
resource "aws_route_table_association" "public_route_table_association_az1" {
  subnet_id = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_table_association_az2" {
  subnet_id = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Private Subnet 1
resource "aws_subnet" "private_app_az1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_app_az1_cidr
  availability_zone = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.environment}-${var.project_name}-private-subnet-app-az1"
    Type        = "private"
  }
}

# Private Subnet 2
resource "aws_subnet" "private_app_az2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_app_az2_cidr
  availability_zone = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment}-${var.project_name}-private-subnet-app-az2"
    Type        = "private"
  }
}


# Route Table for Private Subnets
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${var.environment}-${var.project_name}-private-rtb"
  }
} 

# Route Table Association for Private Subnets
resource "aws_route_table_association" "private_route_table_association_app_az1" {
  subnet_id = aws_subnet.private_app_az1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_route_table_association_app_az2" {
  subnet_id = aws_subnet.private_app_az2.id
  route_table_id = aws_route_table.private_route_table.id
}


# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name = "${var.environment}-${var.project_name}-alb-sg"
  description = "Allow HTTP and HTTPS traffic from the internet"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "Allow HTTP traffic from the internet"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS traffic from the internet"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }                 

  tags = {
    Name = "${var.environment}-${var.project_name}-alb-sg"
  }
}

# Security Group for application server (EC2, ECS)
resource "aws_security_group" "app_server_sg" {
  name = "${var.environment}-${var.project_name}-webserver-sg"
  description = "Security group for application server"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "Allow HTTP traffic from the ALB"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }


  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-${var.project_name}-webserver-sg"
  }
}
/*
# Security Group for Endpoints    
resource "aws_security_group" "eice_sg" {
  name = "${var.environment}-${var.project_name}-eice-sg"
  description = "Outbound SSH to VPC CIDR"
  vpc_id = aws_vpc.vpc.id

  egress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-${var.project_name}-eice-sg"
  }
}



# Security Group for application server (EC2, ECS)
resource "aws_security_group" "app_server_sg" {
  name = "${var.environment}-${var.project_name}-webserver-sg"
  description = "Security group for application server"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "Allow HTTP traffic from the ALB"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description = "Allow HTTPS traffic from the ALB"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_groups = [aws_security_group.dms_sg.id]
  }
  ingress {
    description = "Allow SSH traffic from the endpoints"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [aws_security_group.eice_sg.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-${var.project_name}-webserver-sg"
  }
}

# Security Group for Database Migration Service
resource "aws_security_group" "dms_sg" {
  name = "${var.environment}-${var.project_name}-dms-sg"
  description = "Security group for dms"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH traffic from the endpoints"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [aws_security_group.eice_sg.id]
  }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "${var.environment}-${var.project_name}-dms-sg"
    }
}

# Security Group for Database (RDS)
resource "aws_security_group" "db_sg" {
  name = "${var.environment}-${var.project_name}-db-sg"
  description = "Security group for database (RDS)"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "Allow MySQL traffic from the DMS"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.dms_sg.id]
  }

  ingress { 
    description = "Allow MySQL traffic from the webservers"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.app_server_sg.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-${var.project_name}-db-sg"
  }
}

# Ec2 Instance Connect Endpoint
resource "aws_ec2_instance_connect_endpoint" "ec2_instance_connect_endpoint" {
  subnet_id = aws_subnet.private_app_az1.id
  security_group_ids = [aws_security_group.eice_sg.id]
  tags = {
    Name = "${var.environment}-${var.project_name}-ec2-instance-connect-endpoint"
  }
}
*/