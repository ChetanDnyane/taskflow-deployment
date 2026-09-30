resource "aws_vpc" "taskflow" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "taskflow" {
  vpc_id = aws_vpc.taskflow.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public subnets: EKS worker nodes and internet-facing Kubernetes LoadBalancer.
resource "aws_subnet" "public" {
  count = 3

  vpc_id                  = aws_vpc.taskflow.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name                                                = "${var.project_name}-public-${count.index + 1}"
    "kubernetes.io/role/elb"                            = "1"
    "kubernetes.io/cluster/${var.project_name}-cluster" = "shared"
  }
}

# Private/isolated subnets: RDS only. No NAT Gateway is created.
resource "aws_subnet" "private_db" {
  count = 3

  vpc_id            = aws_vpc.taskflow.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr, 3, count.index + 3)

  tags = {
    Name = "${var.project_name}-db-private-${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.taskflow.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.taskflow.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = 3

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.taskflow.id

  tags = {
    Name = "${var.project_name}-db-private-rt"
  }
}

resource "aws_route_table_association" "private_db" {
  count = 3

  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_db.id
}
