resource "aws_ecr_repository" "projeto-ci-api" {
  name                 = "projeto-ci"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Iac = true
  }
}