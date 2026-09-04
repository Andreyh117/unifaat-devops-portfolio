output "iam_users" {
  description = "Lista de usuários IAM criados"
  value = [
    aws_iam_user.juliana.name,
    aws_iam_user.rafael.name,
    aws_iam_user.lucas.name
  ]
}

output "iam_groups" {
  description = "Lista de grupos IAM criados"
  value = [
    aws_iam_group.developers.name,
    aws_iam_group.platform_eng.name
  ]
}

output "policy_arns" {
  description = "ARNs das custom policies criadas"
  value = {
    s3_read          = aws_iam_policy.s3_read.arn
    ec2_s3_full      = aws_iam_policy.ec2_s3_full.arn
    deny_destructive = aws_iam_policy.deny_destructive.arn
    ec2_role_s3      = aws_iam_policy.ec2_role_policy.arn
  }
}

output "service_role_arn" {
  description = "ARN da Service Role do EC2"
  value       = aws_iam_role.ec2_role.arn
}

output "instance_profile_name" {
  description = "Nome do Instance Profile para o EC2"
  value       = aws_iam_instance_profile.ec2_profile.name
}
