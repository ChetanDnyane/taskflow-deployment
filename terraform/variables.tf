variable "aws_region" {
  description = "AWS region for TaskFlow."
  type        = string
  default     = "ap-southeast-2"
}

variable "project_name" {
  description = "Prefix used for TaskFlow AWS resources."
  type        = string
  default     = "taskflow"
}

variable "vpc_cidr" {
  description = "CIDR block for the TaskFlow VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "eks_version" {
  description = "EKS Kubernetes version. Change if this version is no longer offered."
  type        = string
  default     = "1.34"
}

variable "node_instance_type" {
  description = "EC2 instance type used by the EKS managed node group."
  type        = string
  default     = "t3.small"
}

variable "node_desired_size" {
  type    = number
  default = 1
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 2
}

variable "postgres_engine_version" {
  description = "RDS PostgreSQL engine version."
  type        = string
  default     = "17.11"
}

variable "postgres_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "postgres_allocated_storage" {
  description = "RDS storage in GiB."
  type        = number
  default     = 20
}
