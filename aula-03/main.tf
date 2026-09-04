locals {
  common_tags = {
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Aluno       = var.aluno
    RA          = var.ra
    Disciplina  = "DevOps - UniFAAT 2026-2"
    Aula        = "03"
    Environment = var.environment
  }
}

# 1. GROUPS
resource "aws_iam_group" "developers" {
  name = "${var.ra}-technova-developers"

  # aws_iam_group não possui suporte a tags no IAM da AWS.
}

resource "aws_iam_group" "platform_eng" {
  name = "${var.ra}-technova-platform-eng"

  # aws_iam_group não possui suporte a tags no IAM da AWS.
}

# 2. USERS
resource "aws_iam_user" "juliana" {
  name = "${var.ra}-juliana-dev"
  tags = local.common_tags
}

resource "aws_iam_user" "rafael" {
  name = "${var.ra}-rafael-platform"
  tags = local.common_tags
}

resource "aws_iam_user" "lucas" {
  name = "${var.ra}-lucas-intern"
  tags = local.common_tags
}

# 3. GROUP MEMBERSHIPS
resource "aws_iam_user_group_membership" "juliana_membership" {
  user   = aws_iam_user.juliana.name
  groups = [aws_iam_group.developers.name]
}

resource "aws_iam_user_group_membership" "rafael_membership" {
  user = aws_iam_user.rafael.name
  groups = [
    aws_iam_group.developers.name,
    aws_iam_group.platform_eng.name
  ]
}

resource "aws_iam_user_group_membership" "lucas_membership" {
  user   = aws_iam_user.lucas.name
  groups = [aws_iam_group.developers.name]
}
