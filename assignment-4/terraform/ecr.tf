resource "aws_ecr_repository" "devops_app" {
  name                 = "devops-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = { Name = "devops-app-ecr" }
}

resource "aws_ecr_lifecycle_policy" "devops_app_policy" {
  repository = aws_ecr_repository.devops_app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Keep only 10 most recent tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["main", "feature"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = { type = "expire" }
      }
    ]
  })
}

output "ecr_repository_url" {
  value = aws_ecr_repository.devops_app.repository_url
}