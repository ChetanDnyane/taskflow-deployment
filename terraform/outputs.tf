output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "vpc_id" {
  value = aws_vpc.taskflow.id
}

output "eks_cluster_name" {
  value = aws_eks_cluster.taskflow.name
}

output "eks_update_kubeconfig_command" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.taskflow.name}"
}

output "rds_endpoint" {
  value = aws_db_instance.taskflow.address
}

output "rds_port" {
  value = aws_db_instance.taskflow.port
}

output "rds_master_secret_arn" {
  description = "Secrets Manager ARN holding the RDS master credentials."
  value       = try(aws_db_instance.taskflow.master_user_secret[0].secret_arn, null)
}

output "auth_ecr_url" {
  value = aws_ecr_repository.auth.repository_url
}

output "task_ecr_url" {
  value = aws_ecr_repository.task.repository_url
}

output "ui_ecr_url" {
  value = aws_ecr_repository.ui.repository_url
}
