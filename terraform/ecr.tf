resource "aws_ecr_repository" "auth" {
  name                 = "taskflow-auth-service"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_ecr_repository" "task" {
  name                 = "taskflow-task-service"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_ecr_repository" "ui" {
  name                 = "taskflow-ui"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}