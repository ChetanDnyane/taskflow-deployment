resource "aws_db_subnet_group" "taskflow" {
  name       = "${var.project_name}-db-subnets"
  subnet_ids = aws_subnet.private_db[*].id

  tags = {
    Name = "${var.project_name}-db-subnets"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow PostgreSQL only from TaskFlow EKS workers"
  vpc_id      = aws_vpc.taskflow.id

  ingress {
    description     = "PostgreSQL from EKS workers"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_eks_cluster.taskflow.vpc_config[0].cluster_security_group_id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "taskflow" {
  identifier = "${var.project_name}-postgres"

  engine         = "postgres"
  engine_version = var.postgres_engine_version
  instance_class = var.postgres_instance_class

  allocated_storage = var.postgres_allocated_storage
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = "taskflow"
  username = "postgres"

  # AWS creates and rotates the master password in Secrets Manager.
  # This avoids putting the database password in .tf files or tfvars.
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.taskflow.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible     = false
  multi_az                = false
  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = 0

  tags = {
    Name = "${var.project_name}-postgres"
  }
}
