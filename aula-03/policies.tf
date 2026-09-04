# Policy 1: Leitura estrita no S3 (Somente buckets technova-*)
resource "aws_iam_policy" "s3_read" {
  name        = "${var.ra}-technova-s3-read"
  description = "Permite apenas leitura nos buckets technova"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = ["arn:aws:s3:::technova-*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = ["arn:aws:s3:::technova-*/*"]
      }
    ]
  })

  tags = local.common_tags
}

# Policy 2: Operação de EC2 com condition tag e leitura/escrita no S3.
# DeleteObject não é concedido: Rafael também pertence ao grupo developers,
# cuja policy possui um Deny explícito para operações destrutivas.
resource "aws_iam_policy" "ec2_s3_full" {
  name        = "${var.ra}-technova-ec2-s3-full"
  description = "Operação de EC2 por tag e leitura/escrita nos buckets TechNova"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:Describe*"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["ec2:StartInstances", "ec2:StopInstances"]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Project" = var.project_name
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::technova-*/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::technova-*"
      }
    ]
  })

  tags = local.common_tags
}

# Policy 3: Deny explícito para ações destrutivas de S3 e EC2.
resource "aws_iam_policy" "deny_destructive" {
  name        = "${var.ra}-technova-deny-destructive"
  description = "Deny explícito para exclusões no S3 e término de instâncias EC2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = [
          "s3:Delete*",
          "ec2:Terminate*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = local.common_tags
}

# ANEXOS DAS POLICIES AOS GRUPOS
resource "aws_iam_group_policy_attachment" "dev_s3_read" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.s3_read.arn
}

resource "aws_iam_group_policy_attachment" "dev_deny_destructive" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.deny_destructive.arn
}

resource "aws_iam_group_policy_attachment" "platform_ec2_s3_full" {
  group      = aws_iam_group.platform_eng.name
  policy_arn = aws_iam_policy.ec2_s3_full.arn
}
